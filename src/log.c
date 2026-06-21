#include "log.h"
#include "os.h"

#include <stdarg.h>
#include <stdio.h>
#include <string.h>

// TODO: switch to internal string api once it exists

void LogOutput(LogLevel level, const char *message, ...) {
  // Mirrors log level enumeration indices
  const char *level_strings[6] = {"[FATAL]: ", "[ERROR]: ", "[WARN]: ", "[INFO]: ", "[DEBUG]: ", "[TRACE]: "};

  u16 message_limit = 32000;
  char input_message[message_limit];
  memset(input_message, 0, sizeof(input_message));

  __builtin_va_list arg_ptr;
  va_start(arg_ptr, message);
  vsnprintf(input_message, message_limit, message, arg_ptr);
  va_end(arg_ptr);

  char out_message[message_limit];
  sprintf(out_message, "%s%s\n", level_strings[level], input_message);

  if (level < LOG_LEVEL_WARN) {
    OSWriteStderr(out_message);
  } else {
    OSWriteStdout(out_message);
  }
}

void ReportAssertionFailure(const char *expression, const char *file, i32 line) {
  LogOutput(LOG_LEVEL_FATAL, "Assertion Failure: %s, file: %s, line: %d\n", expression, file, line);
}
