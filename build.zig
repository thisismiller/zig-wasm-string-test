const std = @import("std");
const Builder = std.build.Builder;
const builtin = @import("builtin");

pub fn build(b: *Builder) void {
    const mode = b.standardReleaseOptions();
    const lib = b.addSharedLibrary("wasmtest", "src/main.zig", b.version(0,0,0));
    lib.setBuildMode(mode);
    lib.setTarget(.{.cpu_arch = .wasm32, .os_tag = .freestanding});
    lib.setOutputDir("zig-cache");
    b.default_step.dependOn(&lib.step);
}
