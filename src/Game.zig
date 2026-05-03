const Self = @This();

init: *const fn () anyerror!void,
update: *const fn (delta_time: f64) anyerror!void,
render: *const fn (delta_time: f64) anyerror!void,
deinit: *const fn () void,

window_width: u16,
window_height: u16,
window_title: [*:0]const u8,

const sokol = @import("sokol");
const slog = sokol.log;
const sg = sokol.gfx;
const sapp = sokol.app;
const sglue = sokol.glue;

const state = struct {
    var game: ?*const Self = null;
    var pass_action: sg.PassAction = .{};
};

export fn sokolInit() void {
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

export fn sokolFrame() void {
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

export fn sokolCleanup() void {
    if (state.game) |game| {
        game.deinit();
    }

    sg.shutdown();
}

pub fn run(game: *const Self) void {
    state.game = game;

    sapp.run(.{
        .init_cb = sokolInit,
        .frame_cb = sokolFrame,
        .cleanup_cb = sokolCleanup,
        .width = game.window_width,
        .height = game.window_height,
        .icon = .{ .sokol_default = true },
        .window_title = game.window_title,
        .logger = .{ .func = slog.func },
        .win32 = .{ .console_attach = true },
    });
}
