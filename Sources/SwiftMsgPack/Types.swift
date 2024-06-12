import Foundation

/**
    Enum to represent types of packing with MessagePack.
    Contains byte representation.
*/
public enum MessagePackType: UInt8 {

    internal static let positive_fixint_max: UInt8 = fixmap.rawValue - 1
    internal static let negative_fixint_max: UInt8 = 0xff
    internal static let fixmap_max: UInt8 = fixarray.rawValue - 1
    internal static let fixarray_max: UInt8 = fixstr.rawValue - 1
    internal static let fixstr_max: UInt8 = `nil`.rawValue - 1

    case positive_fixint = 0x00
    case fixmap = 0x80
    case fixarray = 0x90
    case fixstr = 0xa0
    case `nil` = 0xc0
    case `false` = 0xc2
    case `true` = 0xc3
    case bin_8 = 0xc4
    case bin_16 = 0xc5
    case bin_32 = 0xc6
    case ext_8 = 0xc7
    case ext_16 = 0xc8
    case ext_32 = 0xc9
    case float_32 = 0xca
    case float_64 = 0xcb
    case uint_8 = 0xcc
    case uint_16 = 0xcd
    case uint_32 = 0xce
    case uint_64 = 0xcf
    case int_8 = 0xd0
    case int_16 = 0xd1
    case int_32 = 0xd2
    case int_64 = 0xd3
    case fixext_1 = 0xd4
    case fixext_2 = 0xd5
    case fixext_4 = 0xd6
    case fixext_8 = 0xd7
    case fixext_16 = 0xd8
    case str_8 = 0xd9
    case str_16 = 0xda
    case str_32 = 0xdb
    case array_16 = 0xdc
    case array_32 = 0xdd
    case map_16 = 0xde
    case map_32 = 0xdf
    case negative_fixint = 0xe0
}

extension Int: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .int_64)
    }
}

extension Int8: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .int_8)
    }
}

extension Int16: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .int_16)
    }
}

extension Int32: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .int_32)
    }
}

extension Int64: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .int_64)
    }
}

extension UInt: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_64)
    }
}

extension UInt8: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_8)
    }

    /**
        Packs the UInt8 as the fixint type with MessagePack synchronously.

        For positive fixint value has to be in range of 0...127.
        For negative fixint value has to be in range of 0...31.

        - Parameter negative: If true, will pack as a negative fixint, otherwise will pack as a positive fixint

        - Returns: Data with packed bytes or MessagePackError if there was an error during packing.
    */
    public func packWithFixInt(negative: Bool = false) -> Result<Data, MessagePackError> {
        return MessagePacker.packUInt8WithFixInt(value: self, negative: negative)
    }

    /**
        Packs the UInt8 as the fixint type with MessagePack asynchronously.

        For positive fixint value has to be in range of 0...127.
        For negative fixint value has to be in range of 0...31.

        - Parameter negative: If true, will pack as a negative fixint, otherwise will pack as a positive fixint

        - Returns: Data with packed bytes or MessagePackError if there was an error during packing.
    */
    @available(macOS 10.15.0, iOS 15.0, *)
    public func packWithFixInt(negative: Bool = false) async -> Result<Data, MessagePackError> {
        return MessagePacker.packUInt8WithFixInt(value: self, negative: negative)
    }
}

extension UInt16: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_16)
    }
}

extension UInt32: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_32)
    }
}

extension UInt64: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_64)
    }
}

extension Float32: MessagePackable {  // Float
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .float_32)
    }
}

extension Float64: MessagePackable {  // Double, FloatLiteralType
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .float_64)
    }
}

extension String: MessagePackable {

    public func packValue() -> MessagePackValue {
        return .string(self, encoding: .utf8)
    }

    /**
        Packs the String with MessagePack with provided encoding and an optional constraint synchronously.

        If the constraint parameter is not present:
        This will try pack a String with the provided encoding smallest possible format.

        If the constraint parameter is present:
        This will try to pack a structure with the specified constraint
        and a type. It will return an error on packing if it's not possible.
        Constraint parameter should be an ext type (.str_8, .str_16, .str_32).

        - Parameter encoding: Encoding to pack a String with.
        - Parameter constraint: Optional constraint to pack a String with.

        - Returns: Data with packed bytes or MessagePackError if there was an error during packing.
    */
    public func pack(
        with encoding: String.Encoding = .utf8,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        return MessagePacker.packString(value: self, encoding: encoding, constraint: constraint)
    }

    /**
        Packs the String with MessagePack with provided encoding and an optional constraint asynchronously.

        If the constraint parameter is not present:
        This will try pack a String with the provided encoding smallest possible format.

        If the constraint parameter is present:
        This will try to pack a structure with the specified constraint
        and a type. It will return an error on packing if it's not possible.
        Constraint parameter should be an ext type (.str_8, .str_16, .str_32).

        - Parameter encoding: Encoding to pack a String with.
        - Parameter constraint: Optional constraint to pack a String with.

        - Returns: Data with packed bytes or MessagePackError if there was an error during packing.
    */
    @available(macOS 10.15.0, iOS 15.0, *)
    public func pack(
        with encoding: String.Encoding = .utf8,
        constraint: MessagePackType? = nil
    ) async -> Result<Data, MessagePackError> {
        return MessagePacker.packString(value: self, encoding: encoding, constraint: constraint)
    }

}

extension Data: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Date: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Array: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Bool: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: self ? .true : .false)
    }
}

extension Dictionary: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Optional: MessagePackable where Wrapped: MessagePackable {
    public func packValue() -> MessagePackValue {
        switch self {
        case .none:
            return .value(nil)
        case .some(let value):
            return .value(value)
        }
    }
}

/**
    Type representing an Ext type in MessagePack.
*/
public struct Ext: MessagePackable, Equatable {

    /**
        Signed 8 bit Integer representing `type` byte in Ext type.
    */
    public let type: Int8

    /**
        Data containing bytes in Ext type.
    */
    public let data: Data

    /**
        Length of data Ext type contains represented by an unsigned 32 bit Integer.
    */
    public var size: UInt32 {
        UInt32(data.count)
    }

    /**
        Unsigned 8 bit Integer representing `type` byte in Ext type.
    */
    public var utype: UInt8 {
        UInt8(Int(type) - Int(Int8.min))
    }

    public init(type: Int8, data: Data) {
        self.type = type
        self.data = data
    }

    public func packValue() -> MessagePackValue {
        return .value(self)
    }

    public static func == (lhs: Self, rhs: Self) -> Bool {
        return lhs.type == rhs.type && lhs.data == rhs.data
    }

}
