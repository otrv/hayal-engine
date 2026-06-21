#include "render.h"

// TODO: shader needs to be updated manually
#define MAX_TEXTURES 8
#define MAX_TRIANGLES 2048
#define MAX_VERTICES (MAX_TRIANGLES * 3)

typedef struct {
  vec2 pos;
  vec4 color;
  vec2 uv;
  float tex_idx;
} Vertex;

struct Renderer {
  Vertex triangles[MAX_VERTICES];
  u32 textures[MAX_TEXTURES];
  u32 viewport_width;
  u32 viewport_height;
  u32 vao;
  u32 vbo;
  u32 program;
  u32 triangle_count;
  u32 texture_count;
  u32 proj_loc;
};

Renderer RenderInit(u32 viewport_x, u32 viewport_y) {
  Renderer r = {};
  glGenVertexArrays(1, &r.vao);
  glBindVertexArray(r.vao);

  glGenBuffers(1, &r.vbo);
  glBindBuffer(GL_ARRAY_BUFFER, r.vbo);
  glBufferData(GL_ARRAY_BUFFER, MAX_VERTICES * sizeof(Vertex), NULL, GL_DYNAMIC_DRAW);

  glVertexAttribPointer(0, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, pos));
  glEnableVertexAttribArray(0);
  glVertexAttribPointer(1, 4, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, color));
  glEnableVertexAttribArray(1);

  glVertexAttribPointer(2, 2, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, uv));
  glEnableVertexAttribArray(2);
  glVertexAttribPointer(3, 1, GL_FLOAT, GL_FALSE, sizeof(Vertex), (void *)offsetof(Vertex, tex_idx));
  glEnableVertexAttribArray(3);

  r.program = glCreateProgram();

  u32 vert_shader = glCreateShader(GL_VERTEX_SHADER);
  u32 frag_shader = glCreateShader(GL_FRAGMENT_SHADER);

  // TODO: move to a file once we have proper file reading
  const char *vert_code = "#version 330 core\n"
                          "layout (location = 0) in vec2  a_pos;\n"
                          "layout (location = 1) in vec4  a_color;\n"
                          "layout (location = 2) in vec2  a_uv;\n"
                          "layout (location = 3) in float a_texindex;\n"
                          "out vec4  v_color;\n"
                          "out vec2  v_uv;\n"
                          "out float v_texindex;\n"
                          "uniform mat4 u_proj;\n"
                          "void main() {\n"
                          "    gl_Position = u_proj * vec4(a_pos, 0.0, 1.0);\n"
                          "    v_texindex = a_texindex;\n"
                          "    v_uv = a_uv;\n"
                          "    v_color = a_color;\n"
                          "}\n";

  const char *frag_code = "#version 330 core\n"
                          "in vec4  v_color;\n"
                          "in vec2  v_uv;\n"
                          "in float v_texindex;\n"
                          "layout (location=0) out vec4 f_color;\n"
                          "uniform sampler2D u_tex[8];\n"
                          "void main() {\n"
                          "    switch (int(v_texindex)) {\n"
                          "        case 0: f_color = v_color * texture(u_tex[0], v_uv); break;\n"
                          "        case 1: f_color = v_color * texture(u_tex[1], v_uv); break;\n"
                          "        case 2: f_color = v_color * texture(u_tex[2], v_uv); break;\n"
                          "        case 3: f_color = v_color * texture(u_tex[3], v_uv); break;\n"
                          "        case 4: f_color = v_color * texture(u_tex[4], v_uv); break;\n"
                          "        case 5: f_color = v_color * texture(u_tex[5], v_uv); break;\n"
                          "        case 6: f_color = v_color * texture(u_tex[6], v_uv); break;\n"
                          "        case 7: f_color = v_color * texture(u_tex[7], v_uv); break;\n"
                          "        default: discard;\n"
                          "    }\n"
                          "}\n";

  glShaderSource(vert_shader, 1, &vert_code, NULL);
  glShaderSource(frag_shader, 1, &frag_code, NULL);

  glCompileShader(vert_shader);
  glCompileShader(frag_shader);

  // TODO: handle shader compile errors

  glAttachShader(r.program, vert_shader);
  glAttachShader(r.program, frag_shader);

  // TODO: handle shader linking errors

  glLinkProgram(r.program);

  glDetachShader(r.program, vert_shader);
  glDetachShader(r.program, frag_shader);
  glDeleteShader(vert_shader);
  glDeleteShader(frag_shader);

  glUseProgram(r.program);

  r.proj_loc = glGetUniformLocation(r.program, "u_proj");

  u32 tex_loc = glGetUniformLocation(r.program, "u_tex");
  i32 textures[MAX_TEXTURES] = {};
  for (u32 i = 0; i < MAX_TEXTURES; i++) {
    textures[i] = i;
  }
  glUniform1iv(tex_loc, MAX_TEXTURES, textures);

  glEnable(GL_BLEND);
  glBlendFunc(GL_SRC_ALPHA, GL_ONE_MINUS_SRC_ALPHA);

  RenderSetViewport(&r, viewport_x, viewport_y);

  return r;
}

void RenderDeinit(Renderer *r) {
  glDeleteBuffers(1, &r->vbo);
  glDeleteVertexArrays(1, &r->vao);
  glDeleteProgram(r->program);
}

void RenderSetViewport(Renderer *r, u32 viewport_width, u32 viewport_height) {
  r->viewport_width = viewport_width;
  r->viewport_height = viewport_height;
}

void RenderBeginFrame(Renderer *r) {
  mat4 proj_view;
  glm_ortho(0, r->viewport_width, r->viewport_height, 0, -0.01, 1.0, proj_view);
  glUniformMatrix4fv(r->proj_loc, 1, GL_FALSE, (float *)proj_view);
  r->triangle_count = 0;
  r->texture_count = 0;
}

void RenderEndFrame(Renderer *r) {
  for (u32 i = 0; i < r->texture_count; i++) {
    glActiveTexture(GL_TEXTURE0 + i);
    glBindTexture(GL_TEXTURE_2D, r->textures[i]);
  }

  glUseProgram(r->program);
  glBindVertexArray(r->vao);
  glBindBuffer(GL_ARRAY_BUFFER, r->vbo);
  glBufferSubData(GL_ARRAY_BUFFER, 0, r->triangle_count * 3 * sizeof(Vertex), r->triangles);

  glDrawArrays(GL_TRIANGLES, 0, r->triangle_count * 3);
}

void RenderClear(Renderer *r, vec4 color) {
  glClearColor(color[0], color[1], color[2], color[3]);
  glClear(GL_COLOR_BUFFER_BIT);
}

u32 RenderLoadTexture(const char *data, u32 w, u32 h) {
  u32 tex_id;
  glGenTextures(1, &tex_id);
  glBindTexture(GL_TEXTURE_2D, tex_id);
  glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA8, w, h, 0, GL_RGBA, GL_UNSIGNED_BYTE, data);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
  glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
  return tex_id;
}

void RenderFreeTexture(u32 tex_id) {
  glDeleteTextures(1, &tex_id);
}

static void RenderPushTriangle(Renderer *r, vec2 a, vec2 b, vec2 c, vec4 a_color, vec4 b_color, vec4 c_color,
                               vec2 a_uv, vec2 b_uv, vec2 c_uv, u32 tex_id) {

  u32 tex_idx = MAX_TEXTURES;
  for (u32 i = 0; i < r->texture_count; i++) {
    if (r->textures[i] == tex_id) {
      tex_idx = i;
      break;
    }
  }

  if (r->triangle_count == MAX_TRIANGLES || (r->texture_count == MAX_TEXTURES && tex_idx == MAX_TEXTURES)) {
    RenderEndFrame(r);

    r->triangle_count = 0;
    r->texture_count = 0;
    tex_idx = MAX_TEXTURES;
  }

  if (tex_idx == MAX_TEXTURES) {
    ASSERT(r->texture_count < MAX_TEXTURES);
    r->textures[r->texture_count] = tex_id;
    tex_idx = r->texture_count;
    r->texture_count += 1;
  }

  glm_vec2_copy(a, r->triangles[r->triangle_count * 3 + 0].pos);
  glm_vec4_copy(a_color, r->triangles[r->triangle_count * 3 + 0].color);
  glm_vec2_copy(a_uv, r->triangles[r->triangle_count * 3 + 0].uv);
  r->triangles[r->triangle_count * 3 + 0].tex_idx = tex_idx;

  glm_vec2_copy(b, r->triangles[r->triangle_count * 3 + 1].pos);
  glm_vec4_copy(b_color, r->triangles[r->triangle_count * 3 + 1].color);
  glm_vec2_copy(b_uv, r->triangles[r->triangle_count * 3 + 1].uv);
  r->triangles[r->triangle_count * 3 + 1].tex_idx = tex_idx;

  glm_vec2_copy(c, r->triangles[r->triangle_count * 3 + 2].pos);
  glm_vec4_copy(c_color, r->triangles[r->triangle_count * 3 + 2].color);
  glm_vec2_copy(c_uv, r->triangles[r->triangle_count * 3 + 2].uv);
  r->triangles[r->triangle_count * 3 + 2].tex_idx = tex_idx;

  r->triangle_count++;
}

void RenderPushQuad(Renderer *r, vec4 quad, u32 tex_id, vec4 uv, vec4 tint) {
  float x = quad[0], y = quad[1], w = quad[2], h = quad[3];
  float u = uv[0], v = uv[1], uw = uv[2], uh = uv[3];

  RenderPushTriangle(r, (vec2){x, y}, (vec2){x + w, y}, (vec2){x + w, y + h}, tint, tint, tint, (vec2){u, v},
                     (vec2){u + uw, v}, (vec2){u + uw, v + uh}, tex_id);

  RenderPushTriangle(r, (vec2){x, y}, (vec2){x + w, y + h}, (vec2){x, y + h}, tint, tint, tint, (vec2){u, v},
                     (vec2){u + uw, v + uh}, (vec2){u, v + uh}, tex_id);
}

static i32 white_tex_id;

void RenderColoredRect(Renderer *r, vec4 rect, vec4 color) {
  if (!white_tex_id) {
    u8 white_tex[4] = {255, 255, 255, 255};
    white_tex_id = RenderLoadTexture((const char *)white_tex, 1, 1);
  }

  RenderPushQuad(r, rect, white_tex_id, (vec4){0, 0, 1, 1}, color);
}
