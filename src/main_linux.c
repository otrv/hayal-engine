#include "os_linux.c"
#include "render_gl.c"
#include "render.c"

#define RGFW_INT_DEFINED
#define RGFW_OPENGL
#define RGFW_IMPLEMENTATION
#include <RGFW.h>
#define GLM_HEADER_ONLY
#include <cglm/cglm.h>
#include <glad/glad.h>

#define SCREEN_WIDTH 1080
#define SCREEN_HEIGHT 720
#define TARGET_FPS 60

int main(void) {
  RGFW_glHints *hints = RGFW_getGlobalHints_OpenGL();
  hints->major = 3;
  hints->minor = 3;
  RGFW_setGlobalHints_OpenGL(hints);

  RGFW_window *win = RGFW_createWindow("my_game", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
                                       RGFW_windowCenter | RGFW_windowNoResize | RGFW_windowOpenGL);
  if (win == NULL) {
    return -1;
  }
  RGFW_window_makeCurrentContext_OpenGL(win);

  gladLoadGLLoader((GLADloadproc)RGFW_getProcAddress_OpenGL);

  Renderer *renderer = RenderInit(SCREEN_WIDTH, SCREEN_HEIGHT);

  double target_time = 1.0 / TARGET_FPS;
  double last_time = OSGetMonotonicTimeSeconds();

  while (RGFW_window_shouldClose(win) == RGFW_FALSE) {
    double current_time = OSGetMonotonicTimeSeconds();
    double delta_time = current_time - last_time;
    (void)delta_time;
    last_time = current_time;

    RGFW_event event;
    while (RGFW_window_checkEvent(win, &event)) {
      if (event.type == RGFW_windowClose) {
        break;
      }
    }

    RenderBeginFrame(renderer);

    RenderClear(renderer, (vec4){0, 0, 0, 1});
    RenderColoredRect(renderer, (vec4){0, 0, 50, 50}, (vec4){1, 1, 1, 1});

    RenderEndFrame(renderer);

    RGFW_window_swapBuffers_OpenGL(win);

    double elapsed_time = OSGetMonotonicTimeSeconds() - current_time;
    double wait_time = target_time - elapsed_time;
    if (wait_time > 0) {
      OSSleepSeconds(wait_time);
    }
  }

  RenderDeinit(renderer);
  RGFW_window_close(win);
  return 0;
}
