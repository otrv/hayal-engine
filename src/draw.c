#include "draw.h"
#include <stdint.h>

static int32_t white_tex_id;

void DrawColoredRect(Gfx *gfx, vec4 rect, vec4 color) {
  if (!white_tex_id) {
    uint8_t white_tex[4] = {255, 255, 255, 255};
    white_tex_id = GfxLoadTexture((const char *)white_tex, 1, 1);
  }

  GfxPushQuad(gfx, rect, white_tex_id, (vec4){0, 0, 1, 1}, color);
}
