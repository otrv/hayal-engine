const sokol = @import("sokol");

const Self = @This();

init: *const fn () anyerror!void,
update: *const fn (delta_time: f64) anyerror!void,
render: *const fn (delta_time: f64) anyerror!void,
deinit: *const fn () void,

window_width: u16,
window_height: u16,
window_title: [*:0]const u8,
