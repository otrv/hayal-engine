const std = @import("std");
const hayal = @import("hayal");
const Platform = hayal.Platform;
const Renderer = hayal.Renderer;

const GameState = struct {
    renderer: Renderer = .{},
};

fn gameInit(state: *GameState) anyerror!void {
    state.renderer.init();
}

fn gameUpdate(state: *GameState, _: f64) anyerror!void {
    state.renderer.setClearColor(.{ .r = 1, .g = 1, .b = 1, .a = 1 });

    state.renderer.beginPass();

    state.renderer.drawQuad(.{ .x = -0.5, .y = -0.5, .w = 1, .h = 1 }, .{ .r = 0, .g = 0, .b = 0, .a = 1 });

    state.renderer.endPass();
}

fn gameDeinit(state: *GameState) void {
    state.renderer.deinit();
}

pub fn main(_: std.process.Init) !void {
    var state = GameState{};

    var platform = Platform(GameState){
        .window_title = "hayal",
        .window_width = 640,
        .window_height = 480,
        .init_fn = gameInit,
        .frame_fn = gameUpdate,
        .deinit_fn = gameDeinit,
        .user_data = &state,
    };

    platform.run();
}
