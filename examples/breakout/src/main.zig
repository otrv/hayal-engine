const std = @import("std");
const hayal = @import("hayal");

const Io = std.Io;

pub fn main(init: std.process.Init) !void {
    var stdout_buffer: [1024]u8 = undefined;
    var stdout_file_writer: Io.File.Writer = .init(.stdout(), init.io, &stdout_buffer);

    const stdout_writer = &stdout_file_writer.interface;

    try hayal.printAnotherMessage(stdout_writer);

    // Prints to stderr, unbuffered, ignoring potential errors.
    std.debug.print("All your {s} are belong to us.\n", .{"codebase"});

    try stdout_writer.flush();
}
