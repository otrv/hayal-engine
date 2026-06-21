#include "render.h"

void RenderPushQuad(Renderer *r, vec4 quad, u32 tex_id, vec4 uv, vec4 tint) {
  float x = quad[0], y = quad[1], w = quad[2], h = quad[3];
  float u = uv[0], v = uv[1], uw = uv[2], uh = uv[3];

  RenderPushTriangle(r, (vec2){x, y}, (vec2){x + w, y}, (vec2){x + w, y + h}, tint, tint, tint, (vec2){u, v},
                     (vec2){u + uw, v}, (vec2){u + uw, v + uh}, tex_id);

  RenderPushTriangle(r, (vec2){x, y}, (vec2){x + w, y + h}, (vec2){x, y + h}, tint, tint, tint, (vec2){u, v},
                     (vec2){u + uw, v + uh}, (vec2){u, v + uh}, tex_id);
}

static u32 white_tex_id;

void RenderColoredRect(Renderer *r, vec4 rect, vec4 color) {
  if (!white_tex_id) {
    uint8_t white_tex[4] = {255, 255, 255, 255};
    white_tex_id = RenderLoadTexture((const char *)white_tex, 1, 1);
  }

  RenderPushQuad(r, rect, white_tex_id, (vec4){0, 0, 1, 1}, color);
}
