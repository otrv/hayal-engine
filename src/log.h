#ifndef HAYAL_LOG_H
#define HAYAL_LOG_H

#include "core.h"

#define LOG_WARN_ENABLED 1
#define LOG_INFO_ENABLED 1

#ifdef _DEBUG

#define LOG_DEBUG_ENABLED 1
#define LOG_TRACE_ENABLED 1
#else
#define LOG_DEBUG_ENABLED 0
#define LOG_TRACE_ENABLED 0
#endif

typedef enum log_level {
  LOG_LEVEL_FATAL = 0,
  LOG_LEVEL_ERROR = 1,
  LOG_LEVEL_WARN = 2,
  LOG_LEVEL_INFO = 3,
  LOG_LEVEL_DEBUG = 4,
  LOG_LEVEL_TRACE = 5,
} LogLevel;

void LogOutput(LogLevel level, const char *message, ...);

#define HLOG_FATAL(message, ...) LogOutput(LOG_LEVEL_FATAL, message, ##__VA_ARGS__)

#ifndef HERROR
#define HLOG_ERROR(message, ...) LogOutput(LOG_LEVEL_ERROR, message, ##__VA_ARGS__)
#endif

#if LOG_WARN_ENABLED == 1
#define HLOG_WARN(message, ...) LogOutput(LOG_LEVEL_WARN, message, ##__VA_ARGS__)
#else
// Skipts when warn is disabled
#define HLOG_WARN(message, ...) ;
#endif

#if LOG_INFO_ENABLED == 1
#define HLOG_INFO(message, ...) LogOutput(LOG_LEVEL_INFO, message, ##__VA_ARGS__)
#else
// Skipts when info is disabled
#define HLOG_INFO(message, ...)
#endif

#if LOG_DEBUG_ENABLED == 1
#define HLOG_DEBUG(message, ...) LogOutput(LOG_LEVEL_DEBUG, message, ##__VA_ARGS__)
#else
// Skipts when info is disabled
#define HLOG_DEBUG(message, ...)
#endif

#if LOG_TRACE_ENABLED == 1
#define HLOG_TRACE(message, ...) LogOutput(LOG_LEVEL_TRACE, message, ##__VA_ARGS__)
#else
// Skipts when info is disabled
#define HLOG_TRACE(message, ...)
#endif

#endif
