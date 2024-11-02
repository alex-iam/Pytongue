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
    const childScope = try CreateScope(
        allocator,
        &rootScope,
        "main.py",
        Range{
            .start = .{ .line = 0, .character = 0 },
            .end = .{ .line = 100, .character = 0 },
        },
    );
    errdefer allocator.destroy(childScope);

    try rootScope.addChildScope(childScope);
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
