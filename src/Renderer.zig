const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sglue = sokol.glue;

const shd = @import("shaders/quad.glsl.zig");

const Self = @This();

pip: sg.Pipeline = .{},
bind: sg.Bindings = .{},
pass_action: sg.PassAction = .{},
shader: sg.Shader = .{},

pub fn init(self: *Self) void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    self.bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&[_]f32{
            0, 0,
            1, 0,
            1, 1,
            0, 1,
        }),
    });

    self.bind.index_buffer = sg.makeBuffer(.{
        .usage = .{ .index_buffer = true },
        .data = sg.asRange(&[_]u16{ 0, 1, 2, 0, 2, 3 }),
    });

    self.shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend()));

    self.pip = sg.makePipeline(.{
        .shader = self.shader,
        .layout = blk: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_quad_position].format = .FLOAT2;
            break :blk l;
        },
        .index_type = .UINT16,
    });

    self.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 0, .g = 0, .b = 0, .a = 1 },
    };
}

pub const RGBA = struct {
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

pub const Quad = struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
};

pub fn setClearColor(self: *Self, color: RGBA) void {
    self.pass_action.colors[0].clear_value = .{ .r = color.r, .g = color.g, .b = color.b, .a = color.a };
}

pub fn beginPass(self: *Self) void {
    sg.beginPass(.{ .action = self.pass_action, .swapchain = sglue.swapchain() });
}

pub fn drawQuad(self: *Self, quad: Quad, color: RGBA) void {
    sg.applyPipeline(self.pip);
    sg.applyBindings(self.bind);
    sg.applyUniforms(shd.UB_vs_params, sg.asRange(&shd.VsParams{
        .rect = .{ quad.x, quad.y, quad.w, quad.h },
        .color = .{ color.r, color.g, color.b, color.a },
    }));
    sg.draw(0, 6, 1);
}

pub fn endPass(_: *Self) void {
    sg.endPass();
    sg.commit();
}

pub fn deinit(self: *Self) void {
    sg.destroyPipeline(self.pip);
    sg.destroyBuffer(self.bind.vertex_buffers[0]);
    sg.destroyShader(self.shader);
    sg.shutdown();
}
