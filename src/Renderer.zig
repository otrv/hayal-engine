const std = @import("std");
const sokol = @import("sokol");
const shd = @import("shaders/quad.glsl.zig");
const math = @import("math.zig");
const slog = sokol.log;
const sg = sokol.gfx;
const sglue = sokol.glue;
const sapp = sokol.app;

const Self = @This();

const Vertex = extern struct {
    pos: [2]f32,
    color: [4]f32,
};

const MAX_QUADS = 8192;

pip: sg.Pipeline = .{},
bind: sg.Bindings = .{},
pass_action: sg.PassAction = .{},
shader: sg.Shader = .{},
vertices: [MAX_QUADS * 4]Vertex = undefined,
quad_count: u32 = 0,

is_initialized: bool = false,

pub fn setup(self: *Self) void {
    std.debug.assert(!self.is_initialized);

    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    self.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .usage = .{ .stream_update = true, .vertex_buffer = true },
        .size = MAX_QUADS * 4 * @sizeOf(Vertex),
    });

    var indices: [MAX_QUADS * 6]u16 = undefined;
    for (0..MAX_QUADS) |i| {
        const v: u16 = @intCast(i * 4);
        const o = i * 6;
        indices[o + 0] = v + 0;
        indices[o + 1] = v + 1;
        indices[o + 2] = v + 2;
        indices[o + 3] = v + 0;
        indices[o + 4] = v + 2;
        indices[o + 5] = v + 3;
    }
    self.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&indices),
    });

    self.shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend()));

    self.pip = sg.makePipeline(.{
        .shader = self.shader,
        .layout = blk: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_quad_position].format = .FLOAT2;
            l.attrs[shd.ATTR_quad_color0].format = .FLOAT4;
            break :blk l;
        },
        .index_type = .UINT16,
    });

    self.is_initialized = true;
}

pub fn setClearColor(self: *Self, rgba: math.Vec4) void {
    std.debug.assert(self.is_initialized);

    self.pass_action.colors[0].clear_value = .{ .r = rgba[0], .g = rgba[1], .b = rgba[2], .a = rgba[3] };
}

pub fn begin(self: *Self, framebuffer_size: math.Vec2, camera_pos: math.Vec2, camera_zoom: f32) void {
    std.debug.assert(self.is_initialized);

    sg.beginPass(.{ .action = self.pass_action, .swapchain = sglue.swapchain() });
    sg.applyPipeline(self.pip);
    sg.applyBindings(self.bind);

    const proj = math.ortho(0, framebuffer_size[0], framebuffer_size[1], 0, -1, 1);
    const view = math.translate(
        math.scale(math.identity, .{ camera_zoom, camera_zoom, 1 }),
        .{ -camera_pos[0], -camera_pos[1], 0 },
    );
    const view_proj = math.mulMat4(proj, view);

    sg.applyUniforms(shd.UB_vs_globals, sg.asRange(&shd.VsGlobals{ .view_projection = @bitCast(view_proj) }));
}

pub fn drawQuad(self: *Self, pos: math.Vec2, size: math.Vec2, rot: f32, rgba: math.Vec4) void {
    std.debug.assert(self.is_initialized);

    if (self.quad_count >= MAX_QUADS) self.flush();

    const center_x = pos[0] + size[0] * 0.5;
    const center_y = pos[1] + size[1] * 0.5;
    const model = math.translate(
        math.scale(
            math.rotate(
                math.translate(math.identity, .{ center_x, center_y, 0 }),
                rot,
                .{ 0, 0, 1 },
            ),
            .{ size[0], size[1], 1 },
        ),
        .{ -0.5, -0.5, 0 },
    );

    const corners = [_]math.Vec4{
        .{ 0, 0, 0, 1 },
        .{ 1, 0, 0, 1 },
        .{ 1, 1, 0, 1 },
        .{ 0, 1, 0, 1 },
    };

    const base = self.quad_count * 4;
    for (corners, 0..) |corner, i| {
        const world = math.mulMat4Vec4(model, corner);
        self.vertices[base + i] = .{
            .pos = .{ world[0], world[1] },
            .color = rgba,
        };
    }

    self.quad_count += 1;
}

fn flush(self: *Self) void {
    std.debug.assert(self.is_initialized);

    if (self.quad_count == 0) return;
    sg.updateBuffer(self.bind.vertex_buffers[0], sg.asRange(self.vertices[0 .. self.quad_count * 4]));
    sg.draw(0, self.quad_count * 6, 1);
    self.quad_count = 0;
}

pub fn end(self: *Self) void {
    std.debug.assert(self.is_initialized);

    self.flush();
    sg.endPass();
    sg.commit();
}

pub fn destroy(self: *Self) void {
    std.debug.assert(self.is_initialized);

    sg.destroyPipeline(self.pip);
    sg.destroyBuffer(self.bind.vertex_buffers[0]);
    sg.destroyShader(self.shader);
    sg.destroyBuffer(self.bind.index_buffer);
    sg.shutdown();

    self.is_initialized = false;
}
