const std = @import("std");
const Platform = @import("hayal").Platform;

const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sglue = sokol.glue;

const shd = @import("shaders/quad.glsl.zig");

const GameState = struct {};

var pip: sg.Pipeline = .{};
var bind: sg.Bindings = .{};
var pass_action: sg.PassAction = .{};

const Vertex = extern struct {
    x: f32,
    y: f32,
    z: f32,
    r: f32,
    g: f32,
    b: f32,
    a: f32,
};

fn gameInit(_: *GameState) anyerror!void {
    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });

    const vertices = [_]Vertex{
        .{
            .x = 0.0,
            .y = 0.5,
            .z = 0.5,
            .r = 1.0,
            .g = 0.0,
            .b = 0.0,
            .a = 1.0,
        },
        .{
            .x = 0.5,
            .y = -0.5,
            .z = 0.5,
            .r = 0.0,
            .g = 1.0,
            .b = 0.0,
            .a = 1.0,
        },
        .{
            .x = -0.5,
            .y = -0.5,
            .z = 0.5,
            .r = 0.0,
            .g = 0.0,
            .b = 1.0,
            .a = 1.0,
        },
    };
    bind.vertex_buffers[0] = sg.makeBuffer(.{
        .data = sg.asRange(&vertices),
    });

    pip = sg.makePipeline(.{
        .shader = sg.makeShader(shd.quadShaderDesc(sg.queryBackend())),
        .layout = gameInit: {
            var l = sg.VertexLayoutState{};
            l.attrs[shd.ATTR_quad_position].format = .FLOAT3;
            l.attrs[shd.ATTR_quad_color0].format = .FLOAT4;
            break :gameInit l;
        },
    });

    pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 1, .g = 1, .b = 1, .a = 1 },
    };
}

fn gameUpdate(_: *GameState, _: f64) anyerror!void {
    pass_action.colors[0].clear_value = .{ .r = 1, .g = 1, .b = 1, .a = 1 };
    sg.beginPass(.{ .action = pass_action, .swapchain = sglue.swapchain() });

    sg.applyPipeline(pip);
    sg.applyBindings(bind);
    sg.draw(0, 3, 1);

    sg.endPass();
    sg.commit();
}

fn gameDeinit(_: *GameState) void {
    sg.shutdown();
}

pub fn main(_: std.process.Init) !void {
    var state = GameState{};

    var platform = Platform(GameState){
        .window_title = "breakout",
        .window_width = 800,
        .window_height = 400,
        .init_fn = gameInit,
        .frame_fn = gameUpdate,
        .deinit_fn = gameDeinit,
        .user_data = &state,
    };

    platform.run();
}
