const std = @import("std");
const hayal = @import("hayal");

const GameState = struct {};

fn gameInit(_: *GameState) anyerror!void {}

fn gameUpdate(_: *GameState, _: f64) anyerror!void {}

fn gameRender(_: *GameState, _: f64) anyerror!void {}

fn gameDeinit(_: *GameState) void {}

pub fn main(_: std.process.Init) !void {
    var state = GameState{};

    var game: hayal.Game(GameState) = .{
        .window_title = "breakout",
        .window_width = 800,
        .window_height = 400,
        .init_fn = gameInit,
        .update_fn = gameUpdate,
        .render_fn = gameRender,
        .deinit_fn = gameDeinit,
        .user_data = &state,
    };

    game.run();
}
