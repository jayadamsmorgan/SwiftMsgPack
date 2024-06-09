import Foundation

public enum MessagePackType: UInt8 {

    public static let positive_fixint_max: UInt8 = 0x7f
    public static let negative_fixint_max: UInt8 = 0xff
    public static let fixmap_max: UInt8 = fixarray.rawValue - 1
    public static let fixarray_max: UInt8 = fixstr.rawValue - 1
    public static let fixstr_max: UInt8 = `nil`.rawValue - 1

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

extension Int: MessagePackable {  // arch(32) -> Int32 : arch(64) -> Int64
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

extension UInt: MessagePackable {  // arch(32) -> UInt32 : arch(64) -> UInt64
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_64)
    }
}

extension UInt8: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: .uint_8)
    }

    public func packWithFixInt(negative: Bool = false) -> Result<Data, MessagePackError> {
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

    public func pack(
        with encoding: String.Encoding = .utf8,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        return MessagePacker.packString(value: self, encoding: encoding, constraint: constraint)
    }

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

extension Array: MessagePackable where Element: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Bool: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .valueWithOption(self, option: self ? .true : .false)
    }
}

extension Dictionary: MessagePackable where Key: MessagePackable, Value: MessagePackable {
    public func packValue() -> MessagePackValue {
        return .value(self)
    }
}

extension Optional: MessagePackable where Wrapped: MessagePackable {
    public func packValue() -> MessagePackValue {
        switch self {
        case .none:
            return .value(Optional<Wrapped>.none)
        case .some(let value):
            return value.packValue()
        }
    }
}

public struct Ext: MessagePackable {

    public let type: Int8
    public let data: Data

    public var size: UInt32 {
        UInt32(data.count)
    }

    public var utype: UInt8 {
        UInt8(type - Int8.min)
    }

    public init(type: Int8, data: Data) {
        self.type = type
        self.data = data
    }

    public func packValue() -> MessagePackValue {
        return .value(self)
    }

}
