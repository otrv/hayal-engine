#ifndef RENDER_H
#define RENDER_H

#include <cglm/cglm.h>
#include <glad/glad.h>
#include <stdint.h>

typedef struct Renderer Renderer;
Renderer RendererInit(uint32_t viewport_x, uint32_t viewport_y);
void RendererDeinit(Renderer *r);
void RendererSetViewport(Renderer *r, uint32_t viewport_x, uint32_t viewport_y);
void RendererBeginFrame(Renderer *r);
void RendererEndFrame(Renderer *r);
void RendererClear(Renderer *r, vec4 color);
uint32_t RendererLoadTexture(const char *data, uint32_t w, uint32_t h);
void RendererFreeTexture(uint32_t tex_id);
void RendererPushQuad(Renderer *r, vec4 quad, uint32_t tex_id, vec4 uv, vec4 tint);

#endif
