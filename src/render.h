/* HAYAL Render

  OpenGL based 2D renderer. Currently couples rendering backend implementation with high level render
  commands. This approach is chosen due to OpenGL being the single backend. If at some point we want to extend
  with multiple backend it would make sense to separate low level API from the high level API

*/
#ifndef HAYAL_RENDER_H
#define HAYAL_RENDER_H

#include <cglm/cglm.h>
#include <glad/glad.h>
#include "core.h"

// LOW LEVEL API

typedef struct Renderer Renderer;

Renderer *RenderInit(u32 viewport_x, u32 viewport_y);
void RenderDeinit(Renderer *r);
void RenderSetViewport(Renderer *r, u32 viewport_x, u32 viewport_y);
void RenderBeginFrame(Renderer *r);
void RenderEndFrame(Renderer *r);
void RenderClear(Renderer *r, vec4 color);
u32 RenderLoadTexture(const void *data, u32 w, u32 h);
void RenderFreeTexture(u32 tex_id);
void RenderPushTriangle(Renderer *r, vec2 a, vec2 b, vec2 c, vec4 a_color, vec4 b_color, vec4 c_color,
                        vec2 a_uv, vec2 b_uv, vec2 c_uv, u32 tex_id);

// END LOW LEVEL API

// HIGH LEVEL API

void RenderColoredRect(Renderer *r, vec4 rect, vec4 color);
void RenderPushQuad(Renderer *r, vec4 quad, u32 tex_id, vec4 uv, vec4 tint);

// END HIGH LEVEL API

#endif
