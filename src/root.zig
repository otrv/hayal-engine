pub const Game = @import("Game.zig");

const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;

const state = struct {
    var game: ?*const Game = null;
    var pass_action: sg.PassAction = .{};
};

export fn init() void {
    if (state.game) |game| {
        game.init() catch {
            sapp.requestQuit();
            return;
        };
    } else {
        sapp.requestQuit();
    }

    sg.setup(.{
        .environment = sglue.environment(),
        .logger = .{ .func = slog.func },
    });
    state.pass_action.colors[0] = .{
        .load_action = .CLEAR,
        .clear_value = .{ .r = 1, .g = 1, .b = 0, .a = 1 },
    };
}

export fn frame() void {
    const dt: f64 = sapp.frameDuration();
    if (state.game) |game| {
        game.update(dt) catch {
            sapp.requestQuit();
            return;
        };
    }

    const g = state.pass_action.colors[0].clear_value.g + 0.01;
    state.pass_action.colors[0].clear_value.g = if (g > 1.0) 0.0 else g;
    sg.beginPass(.{ .action = state.pass_action, .swapchain = sglue.swapchain() });
    sg.endPass();
    sg.commit();
}

export fn cleanup() void {
    if (state.game) |game| {
        game.deinit();
    }

    sg.shutdown();
}

pub fn run(game: *const Game) void {
    state.game = game;

    sapp.run(.{
        .init_cb = init,
        .frame_cb = frame,
        .cleanup_cb = cleanup,
        .width = game.window_width,
        .height = game.window_height,
        .icon = .{ .sokol_default = true },
        .window_title = game.window_title,
        .logger = .{ .func = slog.func },
        .win32 = .{ .console_attach = true },
    });
}
