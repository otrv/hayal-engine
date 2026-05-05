const std = @import("std");
const hayal = @import("hayal");

const GameState = struct {};

fn gameInit(_: *GameState) anyerror!void {
    std.log.info("Init Breakout", .{});
}

fn gameUpdate(_: *GameState, _: f64) anyerror!void {
    std.log.info("Update Breakout", .{});
}

fn gameRender(_: *GameState, _: f64) anyerror!void {
    std.log.info("Render Breakout", .{});
}

fn gameDeinit(_: *GameState) void {
    std.log.info("Deinit breakout", .{});
}

pub fn main(_: std.process.Init) !void {
    var game_state = GameState{};

    const game: hayal.Game(GameState) = .{
        .window_title = "breakout",
        .window_width = 800,
        .window_height = 400,
        .init_fn = gameInit,
        .update_fn = gameUpdate,
        .render_fn = gameRender,
        .deinit_fn = gameDeinit,
        .user_data = &game_state,
    };

    game.run();
}
