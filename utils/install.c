/*
 * Copyright (c) 2014 Łukasz Szpakowski.
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions
 * are met:
 * 1. Redistributions of source code must retain the above copyright
 *    notice, this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright
 *    notice, this list of conditions and the following disclaimer in the
 *    documentation and/or other materials provided with the distribution.
 * 3. Neither the name of the copyright holder nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS ``AS IS''
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
 * DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS
 * OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION)
 * HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT
 * LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY
 * OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF
 * SUCH DAMAGE.
 */

#include <sys/types.h>
#include <sys/stat.h>
#include <errno.h>
#include <fcntl.h>
#include <grp.h>
#include <libgen.h>
#include <pwd.h>
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#define FLAG_COMPARE			(1 << 0)
#define FLAG_DIRECTORY			(1 << 1)
#define FLAG_MAKE_TARGET_COMPONENTS	(1 << 2)
#define FLAG_GROUP			(1 << 3)
#define FLAG_MODE			(1 << 4)
#define FLAG_OWNER			(1 << 5)
#define FLAG_PRESERVE_TIME		(1 << 6)
#define FLAG_STRIP			(1 << 7)
#define FLAG_TARGET_FILE		(1 << 8)
#define FLAG_TARGET_DIRECTORY		(1 << 9)
#define FLAG_VERBOSE			(1 << 10)

void * xmalloc(size_t size)
{
	void *ptr;
	if((ptr = malloc(size)) == NULL) {
		fprintf(stderr, "Can't allocate memory\n");
		exit(1);
	}
	return ptr;
}

ssize_t xread(int fd, void *buf, size_t size)
{
	ssize_t n = 0, res = 0;
	while(n < size && (res = read(fd, ((char *) buf) +  n, size - n)) > 0) n += res;
	return res >= 0 ? (ssize_t) n : -1;
}

ssize_t xwrite(int fd, const void *buf, size_t size)
{
	ssize_t n = 0, res = 0;
	while(n < size && (res = write(fd, ((char *) buf) + n, size - n)) > 0) n += res;
	return res >= 0 ? (ssize_t) n : -1;
}

char *program_name;

int make_directory(const char *path, int flags)
{
	struct stat buf;
	int res;
	if((res = stat(path, &buf)) == -1 && errno != ENOENT) {
		fprintf(stderr, "%s: %s\n", path, strerror(errno));
		return -1;
	}
	if(res == -1 || !S_ISDIR(buf.st_mode)) {
		if((flags &FLAG_VERBOSE) != 0) printf("%s: creating directory '%s'\n", program_name, path);
		if((res = mkdir(path, 0777)) == -1) {
			fprintf(stderr, "%s: %s\n", path, strerror(errno));
			return -1;
		}
		return 1;
	} else
		return 0;
}

#define BUF_SIZE	4096

int compare_files(const char *path1, const char *path2)
{
	static char buf1[BUF_SIZE];
	static char buf2[BUF_SIZE];
	ssize_t res1 = 0, res2 = 0;
	int fd1 = -1, fd2 = -1, cmp_res = 1, res = 0;
	do {
		if((fd1 = open(path1, O_RDONLY)) == -1) break;
		if((fd2 = open(path2, O_RDONLY)) == -1) break;
		res = 1;
		while((res1 = xread(fd1, buf1, BUF_SIZE)) >= 0 && (res2 = xread(fd2, buf2, BUF_SIZE)) >= 0) {
			if(res1 != res2 && memcpy(buf1, buf2, res1)) {
				cmp_res = 0; break;
			}
			if(res1 == 0) break;
		}
	} while(0);
	if(fd1 != -1) close(fd1);
	if(fd2 != -1) close(fd2);
	return res;
}

int copy_file(const char *src_path, const char *dst_path, int flags)
{
	static char buf[BUF_SIZE];
	ssize_t src_res = 0;
	int src_fd = -1, dst_fd = -1, res = 0;
	if((flags &FLAG_VERBOSE) != 0) printf("%s: copying '%s' to '%s'\n", program_name, src_path, dst_path);
	do {
		if((src_fd = open(src_path, O_RDONLY)) == -1) {
			fprintf(stderr, "%s: %s\n", src_path, strerror(errno));
			res = -1; break;
		}
		if((dst_fd = open(dst_path, O_CREAT | O_WRONLY | O_TRUNC, 0777)) == -1) {
			fprintf(stderr, "%s: %s\n", dst_path, strerror(errno));
			res = -1; break;
		}
		while((src_res = xread(src_fd, buf, BUF_SIZE)) > 0) xwrite(dst_fd, buf, src_res);
		if(src_res == -1) {
			fprintf(stderr, "%s: %s\n", src_path, strerror(errno));
			res = -1; break;
		}
	} while(0);
	if(dst_fd != -1) close(dst_fd);
	if(src_fd != -1) close(src_fd);
	return 0;
}

int strip_file(const char *file_path) {
	pid_t pid;
	if((pid = fork()) == 0) {
		execlp("strip", "strip", file_path, NULL);
		fprintf(stderr, "Can't execute strip program: %s\n", strerror(errno));
		_exit(1);
	} else if(pid != -1) {
		int status;
		if(waitpid(pid, &status, 0) == -1) {
			fprintf(stderr, "%s\n", strerror(errno));
			return -1;
		}
		if(WIFEXITED(status) == 0 || WEXITSTATUS(status) != 0) {
			fprintf(stderr, "Can't strip file\n");
			return -1;
		}
	}
	return 0;
}

int set_attributes(const char *path, int flags, mode_t mode, uid_t uid, gid_t gid)
{
	if((flags & FLAG_MODE) != 0) {
		if(chmod(path, mode) == -1) {
			fprintf(stderr, "%s: %s\n", path, strerror(errno));
			return -1;
		}
	}
	if((flags & FLAG_OWNER) != 0) {
		if(chown(path, uid, -1) == -1) {
			fprintf(stderr, "%s: %s\n", path, strerror(errno));
			return -1;
		}
	}
	if((flags & FLAG_GROUP) != 0) {
		if(chown(path, -1, gid) == -1) {
			fprintf(stderr, "%s: %s\n", path, strerror(errno));
			return -1;
		}
	}
	return 0;
}

int set_dest_time_as_source_time(const char *dst_path, const char *src_path)
{
	struct stat buf;
	struct timeval times[2];
	if(stat(src_path, &buf) == -1) {
		fprintf(stderr, "%s: %s\n", src_path, strerror(errno));
		return -1;
	}
	times[0].tv_sec = buf.st_atim.tv_sec;
	times[0].tv_usec = buf.st_atim.tv_nsec / 1000;
	times[1].tv_sec = buf.st_mtim.tv_sec;
	times[1].tv_usec = buf.st_mtim.tv_nsec / 1000;
	if(utimes(dst_path, times) == -1) {
		fprintf(stderr, "%s: %s\n", src_path, strerror(errno));
		return -1;
	}
	return 0;
}

int make_directories(const char *path, int flags, mode_t mode, uid_t uid, gid_t gid)
{
	char *tmp_path = xmalloc(strlen(path) + 1);
	int *indexes = xmalloc(strlen(path) * sizeof(int) + 1);
	int *reses = xmalloc(strlen(path) * sizeof(int) + 1);
	int i, j, n;
	int res = 0;
	do {
		while(path[j] == '/') j++;
		for(i = 0; path[j] != 0; i++) {
			while(path[j] != '/' && path[j] != 0) j++;
			indexes[i] = j;
			while(path[j] == '/') j++;
		}
		n = i;
		strcpy(tmp_path, path);
		for(i = 0; i < n; i++) {
			char saved_c = tmp_path[indexes[i]];
			tmp_path[indexes[i]] = 0;
			int tmp_res;
			if((tmp_res = make_directory(tmp_path, flags)) == -1) {
				res = -1; break;
			}
			reses[i] = tmp_res;
			tmp_path[indexes[i]] = saved_c;
		}
		if(res == -1) break;
		strcpy(tmp_path, path);
		for(i = n - 1; i >= 0; i--) {
			tmp_path[indexes[i]] = 0;
			if(reses[i] != 0) {
				if(set_attributes(tmp_path, flags, mode, uid, gid) == -1) {
					res = -1; break;
				}
			}
		}
		if(res == -1) break;
	} while(0);
	free(reses);
	free(indexes);
	free(tmp_path);
	return res;
}

int make_file_components(const char *path, int flags, mode_t mode, uid_t uid, gid_t gid)
{
	char *s = strrchr(path, '/');
	char *dir_path = xmalloc(s - path + 1);
	int res;
	memcpy(dir_path, path, s - path);
	dir_path[s - path] = 0;
	res = make_directories(dir_path, flags, mode, uid, uid);
	free(dir_path);
	return res;
}

int install_file_to_file(const char *src_path, const char *dst_path, int flags, mode_t mode, uid_t uid, gid_t gid)
{
	int cmp_res = 0;
	if((flags & FLAG_MAKE_TARGET_COMPONENTS) != 0)
		if(make_file_components(dst_path, flags & ~FLAG_MODE & ~FLAG_OWNER & ~FLAG_GROUP, mode, uid, gid) == -1) return -1;
	if((flags & FLAG_COMPARE) != 0)
		if((cmp_res = compare_files(src_path, dst_path)) == -1) return -1;
	if(!cmp_res) {
		if(copy_file(src_path, dst_path, flags) == -1) return -1;
		if((flags & FLAG_STRIP) != 0) {
			if(strip_file(dst_path) == -1) return -1;
		}
		if(set_attributes(dst_path, flags, mode, uid, gid) == -1) return -1;
		if((flags & FLAG_PRESERVE_TIME) != 0) {
			if(set_dest_time_as_source_time(dst_path, src_path) == -1) return -1;
		}
	}
	return 0;
}

int install_file(const char *src_path, const char *dst_path, int flags, mode_t mode, uid_t uid, gid_t gid)
{
	if((flags & FLAG_TARGET_FILE) != 0)  {
		return install_file_to_file(src_path, dst_path, flags, mode, uid, gid);
	} else {
		char *tmp_src_path;
		char *src_name;
		size_t dst_path_len;
		char *tmp_dst_path;
		int res;
		tmp_src_path = xmalloc(strlen(src_path) + 1);
		strcpy(tmp_src_path, src_path);
		src_name = basename(tmp_src_path);
		dst_path_len = strlen(dst_path);
		tmp_dst_path = xmalloc(dst_path_len + strlen(src_name) + 2);
		strcpy(tmp_dst_path, dst_path);
		tmp_dst_path[dst_path_len] = '/';
		strcpy(tmp_dst_path + dst_path_len + 1, src_name);
		res = install_file_to_file(src_path, tmp_dst_path, flags, mode, uid, gid);
		free(tmp_dst_path);
		free(tmp_src_path);
		return res;
	}
}

int main(int argc, char **argv)
{
	int optc;
	int flags = 0;
	mode_t mode;
	uid_t uid;
	gid_t gid;
	char *dst_path = NULL;
	char *endptr;
	int status = 0;
	program_name = argv[0];
	while((optc = getopt(argc, argv, "cCdDg:m:o:pst:Tv")) != -1) {
		switch(optc) {
		case 'c':
			break;
		case 'C':
			flags |= FLAG_COMPARE;
			break;
		case 'd':
			flags |= FLAG_DIRECTORY;
			break;
		case 'D':
			flags |= FLAG_MAKE_TARGET_COMPONENTS;
			break;
		case 'g':
			gid = strtoul(optarg, &endptr, 10);
			if(*endptr != 0) {
				struct group *group = getgrnam(optarg);
				if(group != NULL) {
					gid = group->gr_gid;
				} else {
					fprintf(stderr, "Invalid group\n");
					return 1;
				}
			}
			flags |= FLAG_GROUP;
			break;
		case 'm':
			mode = strtoul(optarg, &endptr, 8);
			if(*endptr != 0) {
				fprintf(stderr, "Invalid mode\n");
				return 1;
			}
			flags |= FLAG_MODE;
			break;
		case 'o':
			uid = strtoul(optarg, &endptr, 10);
			if(*endptr != 0) {
				struct passwd *passwd = getpwnam(optarg);
				if(passwd != NULL) {
					uid = passwd->pw_gid;
				} else {
					fprintf(stderr, "Invalid owner\n");
					return 1;
				}
			}
			flags |= FLAG_OWNER;
			break;
		case 'p':
			flags |= FLAG_PRESERVE_TIME;
			break;
		case 's':
			flags |= FLAG_STRIP;
			break;
		case 't':
			dst_path = optarg;
			flags |= FLAG_TARGET_DIRECTORY;
			break;
		case 'T':
			flags |= FLAG_TARGET_FILE;
			break;
		case 'v':
			flags |= FLAG_VERBOSE;
			break;
		default:
			fprintf(stderr, "Usage: %s [-cCDpsTv] [-g <group>] [-m <mode>] [-o <owner>] [-t <directory>] <file or directory> ...\n", program_name);
			return 1;
		}
	}
	if((flags & FLAG_DIRECTORY) != 0) {
		int i;
		for(i = optind; i < argc; i++) {
			if(make_directories(argv[i], flags, mode, uid, gid) == -1) status |= 1;
		}
	} else {
		int i;
		if(dst_path == NULL) {
			if(optind + 1 >= argc) {
				fprintf(stderr, "Too few arguments\n");
				return 1;
			}
			argc--;
			dst_path = argv[argc];
		}
		if((flags & FLAG_TARGET_FILE) != 0) {
			if(argc - optind > 1) {
				fprintf(stderr, "Too many arguments\n");
				return 1;
			}
		}
		if(argc - optind == 1) {
			if((flags & FLAG_TARGET_FILE) == 0 && (flags & FLAG_TARGET_DIRECTORY) == 0) {
				struct stat buf;
				if(stat(dst_path, &buf) != -1) {
					if(!S_ISDIR(buf.st_mode)) flags |= FLAG_TARGET_FILE;
				} else if(errno == ENOENT) {
					flags |= FLAG_TARGET_FILE;
				} else {
					fprintf(stderr, "%s: %s\n", dst_path, strerror(errno));
					return 1;
				}
			}
		}
		if((flags & FLAG_TARGET_FILE) == 0 && (flags & FLAG_MAKE_TARGET_COMPONENTS) != 0) {
			if(make_directories(dst_path, flags & ~FLAG_MODE & ~FLAG_OWNER & ~FLAG_GROUP, mode, uid, gid) == -1) return 1;
			flags &= ~FLAG_MAKE_TARGET_COMPONENTS;
		}
		for(i = optind; i < argc; i++) {
			if(install_file(argv[i], dst_path, flags, mode, uid, gid) == -1) status |= 1;
		}
	}
	return status;
}
