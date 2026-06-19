/* HAYAL Render

  OpenGL based 2D renderer. Currently couples rendering backend implementation with high level render
  commands. This approach is chosen due to OpenGL being the single backend. If at some point we want to extend
  with multiple backend it would make sense to separate low level API from the high level API

*/
#ifndef HAYAL_RENDER_H
#define HAYAL_RENDER_H

#include <cglm/cglm.h>
#include <glad/glad.h>
#include <stdint.h>

// LOW LEVEL API

typedef struct Renderer Renderer;

Renderer RenderInit(uint32_t viewport_x, uint32_t viewport_y);
void RenderDeinit(Renderer *r);
void RenderSetViewport(Renderer *r, uint32_t viewport_x, uint32_t viewport_y);
void RenderBeginFrame(Renderer *r);
void RenderEndFrame(Renderer *r);
void RenderClear(Renderer *r, vec4 color);
uint32_t RenderLoadTexture(const char *data, uint32_t w, uint32_t h);
void RenderFreeTexture(uint32_t tex_id);
void RenderPushQuad(Renderer *r, vec4 quad, uint32_t tex_id, vec4 uv, vec4 tint);

// END LOW LEVEL API

// HIGH LEVEL API

void RenderColoredRect(Renderer *r, vec4 rect, vec4 color);

// END HIGH LEVEL API

#endif
