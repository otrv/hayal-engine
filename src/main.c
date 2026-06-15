#define RGFW_OPENGL
#define RGFW_IMPLEMENTATION
#include <RGFW.h>
#include <glad/glad.h>
#include <stdio.h>

int main(void) {
  RGFW_window *win = RGFW_createWindow("my_game", 0, 0, 800, 600,
                                       RGFW_windowCenter | RGFW_windowNoResize | RGFW_windowOpenGL);
  if (win == NULL) {
    printf("Failed to create RGFW window\n");
    return -1;
  }
  RGFW_window_makeCurrentContext_OpenGL(win);

  gladLoadGLLoader((GLADloadproc)RGFW_getProcAddress_OpenGL);

  while (RGFW_window_shouldClose(win) == RGFW_FALSE) {
    RGFW_event event;
    while (RGFW_window_checkEvent(win, &event)) {
      if (event.type == RGFW_windowClose) {
        break;
      }
    }

    glClearColor(0.2f, 0.3f, 0.3f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    RGFW_window_swapBuffers_OpenGL(win);
  }

  RGFW_window_close(win);
  return 0;
}
