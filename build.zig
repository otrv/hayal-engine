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

    // Check step for zls build on save
    const exe_check = b.addExecutable(.{ .name = "hayal", .root_module = mod });
    const check = b.step("check", "Check if foo compiles");
    check.dependOn(&exe_check.step);

    const mod_tests = b.addTest(.{
        .root_module = mod,
    });
    const run_mod_tests = b.addRunArtifact(mod_tests);
    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&run_mod_tests.step);

    // Dynamically create run steps and executables for each example
    const io = b.graph.io;
    const examples_dir = b.build_root.handle.openDir(io, "examples", .{ .iterate = true }) catch {
        return;
    };
    defer examples_dir.close(io);
    var examples_it = examples_dir.iterate();
    while (examples_it.next(io) catch null) |entry| {
        if (entry.kind != .directory) continue;
        const ex_name = b.dupe(entry.name);
        const ex_mod = b.addModule(ex_name, .{ .root_source_file = b.path(b.fmt("examples/{s}/src/main.zig", .{ex_name})), .target = target, .optimize = optimize, .imports = &.{
            .{ .name = "hayal", .module = mod },
        } });
        const ex_exe = b.addExecutable(.{
            .name = ex_name,
            .root_module = ex_mod,
        });

        const run_step = b.step(b.fmt("run-{s}", .{ex_name}), b.fmt("Run example {s}", .{ex_name}));
        const run_cmd = b.addRunArtifact(ex_exe);
        run_step.dependOn(&run_cmd.step);
        run_cmd.step.dependOn(b.getInstallStep());
        if (b.args) |args| {
            run_cmd.addArgs(args);
        }
    }
}
