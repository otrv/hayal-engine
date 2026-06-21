#!/usr/bin/sh

clang src/main_linux.c vendor/glad/glad.c \
  --std=c99 -Wall -Werror -fsanitize=address \
  -isystem ./vendor \
  -lX11 -lGLX -lm -lXrandr -ldl \
  -D_DEBUG \
  -o my_game
