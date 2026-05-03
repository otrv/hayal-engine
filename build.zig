const std = @import("std");

pub fn build(b: *std.Build) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    const mod = b.addModule("hayal", .{
        .root_source_file = b.path("src/root.zig"),
        .target = target,
    });

    const lib = b.addLibrary(.{ .name = "hayal", .root_module = mod, .linkage = .dynamic });
    b.installArtifact(lib);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // We need to register each example directory as a module for ZLS to detect their dependencies
    const io = b.graph.io;
    const examples_dir = b.build_root.handle.openDir(io, "examples", .{ .iterate = true }) catch {
        return;
    };
    defer examples_dir.close(io);
    var examples_it = examples_dir.iterate();
    while (examples_it.next(io) catch null) |entry| {
        if (entry.kind != .directory) continue;
        const name = b.dupe(entry.name);
        _ = b.addModule(name, .{ .root_source_file = b.path(b.fmt("examples/{s}/src/main.zig", .{name})), .target = target, .optimize = optimize, .imports = &.{
            .{ .name = "hayal", .module = mod },
        } });
    }

    const example_program = b.option([]const u8, "example", "The example to build as an executable");
    if (example_program) |program| {
        const exe = b.addExecutable(.{
            .name = example_program.?,
            .root_module = b.createModule(.{
                .root_source_file = b.path(b.fmt("examples/{s}/src/main.zig", .{program})),
                .target = target,
                .optimize = optimize,
                .imports = &.{
                    .{ .name = "hayal", .module = mod },
                },
            }),
        });
        b.installArtifact(exe);

        const run_step = b.step("run", "Run the app");
        const run_cmd = b.addRunArtifact(exe);
        run_step.dependOn(&run_cmd.step);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
