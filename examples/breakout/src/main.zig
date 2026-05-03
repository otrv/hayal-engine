const std = @import("std");
const hayal = @import("hayal");

fn gameInit() anyerror!void {
    std.log.info("Init Breakout", .{});
}

fn gameUpdate(_: f64) anyerror!void {
    std.log.info("Update Breakout", .{});
}

fn gameRender(_: f64) anyerror!void {
    std.log.info("Render Breakout", .{});
}

fn gameDeinit() void {
    std.log.info("Deinit breakout", .{});
}

pub fn main(_: std.process.Init) !void {
    const game: hayal.Game = .{
        .window_title = "breakout",
        .window_width = 800,
        .window_height = 400,
        .init = gameInit,
        .update = gameUpdate,
        .render = gameRender,
        .deinit = gameDeinit,
    };

    game.run();
}
