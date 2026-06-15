#!/usr/bin/sh

clang src/main.c vendor/glad/glad.c \
  --std=c99 -Wall -Werror -fsanitize=address \
  -isystem ./vendor \
  -lX11 -lGLX -lm -lXrandr -ldl -lpthread -lm \
  -o my_game
