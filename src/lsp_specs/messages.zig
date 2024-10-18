const types = @import("lsp_types.zig");
pub const Message = struct {
    const jsonrpc: []const u8 = "2.0";
};

pub const RequestMessage = struct {
    const jsonrpc: []const u8 = "2.0";
    const id: types.IntOrString = types.IntOrString{ .string = "" };
    const method: []const u8 = "";
    const params: ?types.ObjectOrArray = null;
};
