// This file is a part of Pytongue.
//
// Copyright (C) 2024 Oleksandr Korzh
//
// Pytongue is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Pytongue is distributed in the hope that it will be useful, but
// WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Pytongue. If not, see <https://www.gnu.org/licenses/>.

const std = @import("std");
const StateManager = @import("state.zig").StateManager;
const Handler = @import("handlers.zig").Handler;
const ec = @import("../lsp_specs/error_codes.zig");
const MAX_HEADER_SIZE = 256;

pub const Server = struct {
    stateManager: *StateManager,
    handler: *Handler,
    fn parseRequest(_: *Server, allocator: std.mem.Allocator) ![]const u8 {
        std.log.debug("server parseRequest", .{});

        var reader = std.io.getStdIn().reader();

        var headers = std.ArrayList(u8).init(allocator);
        defer headers.deinit();

        var totalRead: usize = 0;
        while (totalRead < MAX_HEADER_SIZE) {
            const line = reader.readUntilDelimiterAlloc(
                allocator,
                '\n',
                std.math.maxInt(usize),
            ) catch |err| {
                switch (err) {
                    error.EndOfStream => return allocator.dupe(u8, ""),
                    else => return err,
                }
            };
            defer allocator.free(line);
            if (line.len == 1 and line[0] == '\r') {
                break;
            }
            try headers.appendSlice(line);
            try headers.append('\n');
            totalRead += line.len + 1;
        }

        if (totalRead >= MAX_HEADER_SIZE) {
            return error.HeaderTooLarge;
        }

        if (headers.items.len == 0) {
            return error.NoHeaders;
        }

        var contentLength: ?usize = null;
        var it = std.mem.split(u8, headers.items, "\r\n");
        while (it.next()) |header| {
            if (std.mem.startsWith(u8, header, "Content-Length: ")) {
                contentLength = std.fmt.parseInt(usize, header[16..], 10) catch {
                    return error.InvalidContentLength;
                };
                break;
            }
        }

        if (contentLength == null) {
            return error.MissingContentLength;
        }

        const content = try allocator.alloc(u8, contentLength.?);
        errdefer allocator.free(content);

        const bytesRead = try reader.readAll(content);
        if (bytesRead != contentLength) {
            return error.UnexpectedEOF;
        }
        std.log.debug("server finished parsing", .{});
        return content;
    }

    fn sendResponse(_: *Server, response: []const u8) void {
        std.log.debug("server sendResponse", .{});
        const stdout = std.io.getStdOut().writer();
        stdout.print("Content-Length: {d}\r\n\r\n", .{response.len}) catch unreachable;
        stdout.writeAll(response) catch unreachable;
    }

    pub fn serve(self: *Server, allocator: std.mem.Allocator) !void {
        std.log.debug("server serve", .{});
        try self.stateManager.startServer();
        while (self.stateManager.shouldBeRunning()) {
            const request = self.parseRequest(allocator) catch |err| {
                std.log.debug("server failed to parse request: {any}", .{err});
                const e = self.handler.makeError(ec.ParseError, "Request parsing failed");
                self.sendResponse(e);
                continue;
            };
            if (request.len == 0) {
                std.log.debug("server serve empty request", .{});
                continue;
            }
            if (self.handler.handle(request)) |response| {
                self.sendResponse(response);
            }
        }
    }
};
