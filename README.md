# Hayal

This project builds a game/game engine with minimum dependencies. Over time the goal is to pull layers into their own libraries
for quick prototyping.

> [!CAUTION]
> This project is built for my personal usage and it is very early in development. As such it is heavily underdocumented and lacks a lot of basic features. If you want to try it out or extend it you would need to dive into the code.

> [!NOTE]
> Hayal is not built as an engine but a game. To use it, you are expected to fork the repo.

### Platform

Linux is currenty the only supported target. If you want to add support for other platforms you need to implement `os_<platform>.c` , create a new `main_<platform>.c` and a new build script. 

### Graphics API

The project currently only supports OpenGL through `render_gl.c`. To add support for other graphics APIs simply reimplement this file as `render_<api>.c`.

### Building a game

Simply replace the `main_<platform>.c` file with your own implementation. The entry file is expected to be built as the single platform specific main file to be the sole compile target (unity build) so all of the implementation files should be included and the selected graphics API implementation should be imported.


## Building the game

**This only outputs a debug build at the moment.**

### Linux

```bash
./build.sh
```

