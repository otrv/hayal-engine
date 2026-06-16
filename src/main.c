#include "render.h"
#define RGFW_OPENGL
#define RGFW_IMPLEMENTATION
#include <RGFW.h>
#define GLM_HEADER_ONLY
#include <cglm/cglm.h>

#include "render.c"

#include <glad/glad.h>
#include <stdio.h>

#define SCREEN_WIDTH 1080
#define SCREEN_HEIGHT 720

int main(void) {
  RGFW_window *win = RGFW_createWindow("my_game", 0, 0, SCREEN_WIDTH, SCREEN_HEIGHT,
                                       RGFW_windowCenter | RGFW_windowNoResize | RGFW_windowOpenGL);
  if (win == NULL) {
    printf("Failed to create RGFW window\n");
    return -1;
  }
  RGFW_window_makeCurrentContext_OpenGL(win);

  gladLoadGLLoader((GLADloadproc)RGFW_getProcAddress_OpenGL);

  Renderer renderer = RendererInit(SCREEN_WIDTH, SCREEN_HEIGHT);

  uint8_t white_tex[4] = {255, 255, 255, 255};
  uint8_t white_tex_id = RendererLoadTexture((const char *)white_tex, 1, 1);

  while (RGFW_window_shouldClose(win) == RGFW_FALSE) {
    RGFW_event event;
    while (RGFW_window_checkEvent(win, &event)) {
      if (event.type == RGFW_windowClose) {
        break;
      }
    }

    RendererBeginFrame(&renderer);

    RendererClear(&renderer, (vec4){0, 0, 0, 1});
    RendererPushQuad(&renderer, (vec4){0, 0, 50, 50}, white_tex_id, (vec4){0, 0, 1, 1}, (vec4){1, 1, 1, 1});

    RendererEndFrame(&renderer);

    RGFW_window_swapBuffers_OpenGL(win);
  }

  RendererFreeTexture(white_tex_id);

  RGFW_window_close(win);
  return 0;
}
