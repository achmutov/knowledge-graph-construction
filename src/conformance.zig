const std = @import("std");

const TestMetadata = struct {
    id: []const u8,
    mapping: []const u8,
    output_format1: ?[]const u8,
    output_format2: ?[]const u8,
    output_format3: ?[]const u8,
    output1: ?[]const u8,
    output2: ?[]const u8,
    output3: ?[]const u8,
    @"error": bool,
};

const TestIterator = struct {
    metadata: []const u8,
    row_it: std.mem.SplitIterator(u8, .sequence),

    pub fn next(self: *@This()) ?TestMetadata {
        const row = self.row_it.next() orelse "";
        if (row.len == 0) {
            return null;
        }

        // Collect fields
        var j: usize = 0;
        var field_it = std.mem.splitScalar(u8, row, ',');
        var fields_buf: [100][]const u8 = undefined;
        while (field_it.next()) |field| {
            fields_buf[j] = field;
            j += 1;
        }

        // Save metadata
        const map_empty_null = struct {
            fn func(value: []const u8) ?[]const u8 {
                return if (std.mem.eql(u8, value, ""))
                    null
                else
                    value;
            }
        }.func;
        return .{
            .id = fields_buf[0],
            .mapping = fields_buf[j - 14],
            // Read from behind to skip title/description, which might have commas
            .output_format1 = map_empty_null(fields_buf[j - 10]),
            .output_format2 = map_empty_null(fields_buf[j - 9]),
            .output_format3 = map_empty_null(fields_buf[j - 8]),
            .output1 = map_empty_null(fields_buf[j - 4]),
            .output2 = map_empty_null(fields_buf[j - 3]),
            .output3 = map_empty_null(fields_buf[j - 2]),
            .@"error" = std.mem.eql(u8, fields_buf[j - 1], "true"),
        };
    }
};

fn parseMetadata(content: []const u8) TestIterator {
    // Find delimiter: \n or \r or \r\n
    const delimiter = blk: {
        for (content[0..content.len - 1], content[1..content.len]) |a, b| {
            switch (a) {
                '\n' => break,
                '\r' => switch (b) {
                    '\n' => break :blk "\r\n",
                    else => break :blk "\r",
                },
                else => {},
            }
        }
        break :blk "\n";
    };

    var row_it = std.mem.splitSequence(u8, content, delimiter);
    _ = row_it.next(); // Skip header
    return .{
        .row_it = row_it,
        .metadata = content,
    };

}

comptime {
    @setEvalBranchQuota(1000000);
    for ([_][]const u8 {
        "rml-core",
        "rml-io",
        "rml-fnml",
        "rml-cc",
        "rml-star",
    }) |module| {
        const content = @embedFile("data/" ++ module ++ "/test-cases/metadata.csv");
        var test_it = parseMetadata(content);
        while (test_it.next()) |x| {
            _ = struct {
                // FIXME: Zig uses identifier name instead of its contents
                const conformance = x.id;
                test conformance {
                    return error.todo;
                }
            };
        }
    }
}
