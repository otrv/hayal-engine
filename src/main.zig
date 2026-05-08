const std = @import("std");
const hayal = @import("hayal");
const Platform = hayal.Platform;
const Renderer = hayal.Renderer;

const GameState = struct {
    renderer: Renderer = .{},
};

fn gameInit(state: *GameState) anyerror!void {
    state.renderer.setup();
}

fn gameUpdate(state: *GameState, _: f64, framebuffer_size: [2]f32) anyerror!void {
    state.renderer.setClearColor(.{ 0, 0, 0, 1 });

    state.renderer.beginPass(framebuffer_size, .{ 0, 0 }, 1);

    state.renderer.endPass();
}

fn gameDeinit(state: *GameState) void {
    state.renderer.destroy();
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
