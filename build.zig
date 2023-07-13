const std = @import("std");
const zlib = @import("zlib.zig");

pub fn build(b: *std.build.Builder) void {
    const target = b.standardTargetOptions(.{});
    const optimize = b.standardOptimizeOption(.{});

    // Modules available to downstream dependencies
    _ = b.addModule("zlib", .{
        .source_file = .{ .path = (comptime thisDir()) ++ "/src/main.zig" },
    });

    const lib = zlib.create(b, target, optimize);
    b.installArtifact(lib.step);

    const tests = b.addTest(.{
        .root_source_file = .{ .path = "src/main.zig" },
    });
    lib.link(tests, .{});

    const test_step = b.step("test", "Run tests");
    test_step.dependOn(&tests.step);

    const bin = b.addExecutable(.{
        .name = "example1",
        .root_source_file = .{ .path = "example/example1.zig" },
        .target = target,
        .optimize = optimize,
    });
    lib.link(bin, .{ .import_name = "zlib" });
    b.installArtifact(bin);
}

/// Path to the directory with the build.zig.
fn thisDir() []const u8 {
    return std.fs.path.dirname(@src().file) orelse unreachable;
}
