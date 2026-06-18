#ifndef HAYAL_GFX_H
#define HAYAL_GFX_H

#include <cglm/cglm.h>
#include <glad/glad.h>
#include <stdint.h>

typedef struct Gfx Gfx;
Gfx GfxInit(uint32_t viewport_x, uint32_t viewport_y);
void GfxDeinit(Gfx *r);
void GfxSetViewport(Gfx *r, uint32_t viewport_x, uint32_t viewport_y);
void GfxBeginFrame(Gfx *r);
void GfxEndFrame(Gfx *r);
void GfxClear(Gfx *r, vec4 color);
uint32_t GfxLoadTexture(const char *data, uint32_t w, uint32_t h);
void GfxFreeTexture(uint32_t tex_id);
void GfxPushQuad(Gfx *r, vec4 quad, uint32_t tex_id, vec4 uv, vec4 tint);

#endif
