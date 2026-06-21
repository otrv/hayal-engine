#define _POSIX_C_SOURCE 199309L
#include "os.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <sys/mman.h>

double OSGetMonotonicTimeSeconds() {
  struct timespec t;
  clock_gettime(CLOCK_MONOTONIC, &t);
  return t.tv_sec + t.tv_nsec * 1e-9;
};
void OSSleepSeconds(double secs) {
  struct timespec ts = {.tv_sec = (time_t)secs, .tv_nsec = (long)((secs - (time_t)secs) * 1e9)};
  nanosleep(&ts, NULL);
}

void *OSMemAlloc(u64 size) {
  return malloc(size);
}
void OSMemFree(void *block) {
  free(block);
}

void *OSMemReserve(u64 size) {
  return mmap(NULL, size, PROT_NONE, MAP_ANONYMOUS | MAP_PRIVATE, -1, 0);
}

b32 OSMemCommit(void *ptr, u64 size) {
  u8 res = mprotect(ptr, size, PROT_READ | PROT_WRITE);
  return res == 0;
}

void *OSMemCopy(void *dest, const void *src, u64 size) {
  return memcpy(dest, src, size);
}

void *OSMemSet(void *dest, i32 value, u64 size) {
  return memset(dest, value, size);
}

void OSWriteStdout(const char *message) {
  printf("%s", message);
}

void OSWriteStderr(const char *message) {
  fprintf(stderr, "%s", message);
}
