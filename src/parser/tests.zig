const std = @import("std");
const testing = std.testing;
const Scope = @import("symbol_table.zig").Scope;
const Symbol = @import("symbol_table.zig").Symbol;
const Range = @import("lsp_specs").lsp_types.Range;
const Position = @import("lsp_specs").lsp_types.Position;
const CreateScope = @import("symbol_table.zig").CreateScope;

test "scope: init and deinit" {
    const allocator = std.testing.allocator;
    var rootScope = Scope.init(allocator, null, "src", null);
    defer rootScope.deinit();
    try testing.expectEqual(rootScope.uri, "src");
}

test "scope: add child scope" {
    const allocator = std.testing.allocator;
    var rootScope = Scope.init(allocator, null, "src", null);
    defer rootScope.deinit();
    const childScope = try CreateScope(
        allocator,
        &rootScope,
        "src/main.py",
        Range{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 100, .character = 0 },
        },
    );
    try rootScope.addChildScope(childScope);
    try testing.expectEqual(childScope, rootScope.children.getLast());
}

test "scope: add and get symbols" {
    const allocator = std.testing.allocator;
    var rootScope = Scope.init(allocator, null, "src", null);
    defer rootScope.deinit();
    const symbol = Symbol{
        .name = "test",
        .kind = .Variable,
        .position = .{ .line = 0, .character = 0 },
        .scope = &rootScope,
        .docstring = "Hello world",
        .references = std.ArrayList(Position).init(allocator),
    };
    try rootScope.addSymbol(symbol);
    const foundSymbol = rootScope.getSymbol("test");
    try testing.expect(foundSymbol != null);
    try testing.expect(std.mem.eql(u8, foundSymbol.?.name, symbol.name));
}

test "scope: find innermost: deep in tree" {
    const allocator = std.testing.allocator;
    var rootScope = Scope.init(allocator, null, "src", null);
    defer rootScope.deinit();
    const childScope = try CreateScope(
        allocator,
        &rootScope,
        "src/main.py",
        Range{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 100, .character = 0 },
        },
    );
    try rootScope.addChildScope(childScope);
    const grandChildScope = try CreateScope(
        allocator,
        childScope,
        "src/main.py",
        Range{
            .start = .{ .line = 20, .character = 0 },
            .end = .{ .line = 40, .character = 0 },
        },
    );
    try childScope.addChildScope(grandChildScope);
    const secondChildScope = try CreateScope(
        allocator,
        &rootScope,
        "src/hello.py",
        Range{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 50, .character = 0 },
        },
    );
    try rootScope.addChildScope(secondChildScope);
    const foundScope = rootScope.findInnermostScope(
        .{
            .textDocument = .{
                .uri = "src/main.py",
            },
            .position = .{
                .line = 30,
                .character = 15,
            },
        },
    );
    try testing.expectEqual(grandChildScope, foundScope);
}
