const std = @import("std");

var allocator: std.mem.Allocator = undefined;

// Initialize any starting state.  This is automatically called after the
// WASM is loaded by the browser.
//
// The allocator could be assigned at global scope, but this is an example.
export fn start() void {
    // Implemented by std.heap.WasmPageAllocator on wasm32.
    allocator = std.heap.page_allocator;
}

// For JS to give Zig a string, the string must be in WASM memory.  It's not
// safe to just write anywhere, as it doesn't know what's allocated and free.
// Thus, we expose a way for JS to get an arbitrary block of memory to use to
// pass to Zig.
export fn alloc(size: u32) [*]const u8 {
    const slice = allocator.alloc(u8, size) catch @panic("alloc: allocator.alloc");
    return slice.ptr;
}

// An arbitrary computation, which returns a newly allocated string.
export fn double(ptr: [*]u8, size: u32) [*:0]u8 {
    var in_slice: []u8 = ptr[0..size];
    var out_str: []u8 = allocator.alloc(u8, size * 2 + 1) catch @panic("double: allocator.alloc");
    std.mem.copy(u8, out_str[0..size], in_slice);
    std.mem.copy(u8, out_str[size .. size * 2], in_slice);
    out_str[size * 2] = 0;
    return out_str[0 .. out_str.len - 1 :0].ptr;
}

// The string returned by `double` is owned by `allocator`, and thus JS will
// need to call into WASM to have it freed by `allocator` as well.
export fn free(ptr: [*]u8, size: u32) void {
    allocator.free(ptr[0..size]);
}
