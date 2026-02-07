const std = @import("std");

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

pub fn isStruct(comptime T: type) bool {
    return @typeInfo(T) == .@"struct";
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/// UInt(bits) returns an unsigned integer type of the requested bit width.
pub fn UInt(comptime bits: u8) type {
    return @Int(.unsigned, bits);
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/// Returns an unsigned integer type with ***at least*** `min_bits`,
/// that is also large enough to be addressable by a normal pointer.
/// The returned type will always be one of the following:
/// * `u8`
/// * `u16`
/// * `u32`
/// * `u64`
/// * `u128`
/// * `u256`
pub fn AddressableUInt(comptime min_bits: u8) type {
    return switch (min_bits) {
        0...8 => u8,
        9...16 => u16,
        17...32 => u32,
        33...64 => u64,
        65...128 => u128,
        129...255 => u256,
    };
}

// - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

/// Given: `Struct = struct { foo: u32, bar: u64 }`
/// Returns: `StructOfSlices = struct { foo: []u32, bar: []u64 }`
pub fn StructOfSlices(comptime Struct: type) type {
    const struct_fields = @typeInfo(Struct).@"struct".fields;

    return @Struct(.auto, null, names: {
        var names: [struct_fields.len][:0]const u8 = undefined;
        for (struct_fields, 0..) |f, i| names[i] = f.name;
        break :names &names;
    }, types: {
        var types: [struct_fields.len]type = undefined;
        for (struct_fields, 0..) |f, i| types[i] = []f.type;
        break :types &types;
    }, attrs: {
        var attrs: [struct_fields.len]std.builtin.Type.StructField.Attributes = undefined;
        for (struct_fields, 0..) |f, i| attrs[i] = .{ .@"align" = @alignOf([]f.type) };
        break :attrs &attrs;
    });
}

test "StructOfSlices" {
    const expectEqual = std.testing.expectEqual;

    const Struct = struct { a: u16, b: u16, c: u16 };
    try expectEqual(@sizeOf(u16) * 3, @sizeOf(Struct));

    const SOS = StructOfSlices(Struct);
    try expectEqual(@sizeOf([]u16) * 3, @sizeOf(SOS));
}
