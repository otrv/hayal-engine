#ifndef HAYAL_PLATFORM_H
#define HAYAL_PLATFORM_H

#include "core.h"

double OSGetMonotonicTimeSeconds();
void OSSleepSeconds(double secs);

void *OSMemAlloc(u64 size);
void *OSMemReserve(u64 size);
b32 OSMemCommit(void *ptr, u64 size);
void OSMemFree(void *ptr);
void *OSMemCopy(void *dest, const void *src, u64 size);
void *OSMemSet(void *dest, i32 value, u64 size);

void OSWriteStdout(const char *message);
void OSWriteStderr(const char *message);

#endif
