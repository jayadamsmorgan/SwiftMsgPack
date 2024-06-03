import Foundation

public enum MessagePackError: Error {
    case unknownType
    case invalidData
    case notImplemented
}

public enum MessagePackValue {
    case value(any MessagePackableValue)
    case valueWithOption(any MessagePackableValue, option: MessagePackType)
    case string(String, encoding: String.Encoding = .utf8)
    case structure([MessagePackValue])
}

public protocol MessagePackableValue {
    func packValue() -> MessagePackValue
}

public protocol MessagePackable: MessagePackableValue {
    var structId: any UnsignedInteger { get }
}

public extension MessagePackableValue {

    func pack() -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
        case .value(let value):
            return packWithOption(value: value)
        case .valueWithOption(let value, let option):
            return packWithOption(value: value, option: option)
        case .string(let value, let encoding):
            return packString(value: value, encoding: encoding)
        case .structure(let values):
            return packStructure(values: values)
        }
    }

    private func packWithOption(value: any MessagePackableValue) -> Result<Data, MessagePackError> {
        switch value {
        case is Int:
            return packWithOption(value: value, option: .int_64)
        case is Int8:
            return packWithOption(value: value, option: .int_8)
        case is Int16:
            return packWithOption(value: value, option: .int_16)
        case is Int32:
            return packWithOption(value: value, option: .int_32)
        case is Int64:
            return packWithOption(value: value, option: .int_64)
        case is UInt:
            return packWithOption(value: value, option: .uint_64)
        case is UInt8:
            return packWithOption(value: value, option: .uint_8)
        case is UInt16:
            return packWithOption(value: value, option: .uint_16)
        case is UInt32:
            return packWithOption(value: value, option: .uint_32)
        case is UInt64:
            return packWithOption(value: value, option: .uint_64)
        case is Float32:
            return packWithOption(value: value, option: .float_32)
        case is Float64:
            return packWithOption(value: value, option: .float_64)
        case is String:
            return packString(value: value, encoding: .utf8)
        case is Data:
            return packWithOption(value: value, option: .bin_32)
        case is Array<any MessagePackableValue>:
            return packWithOption(value: value, option: .array_32)
        case is Bool:
            return packWithOption(value: value, option: self as! Bool ? .true : .false)
        // case is Dictionary<MesssagePackableValue, MessagePackable>:  // ????
        //     break
        default:
            return .failure(.unknownType)
        }
    }

    func pack() async -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
        case .value(let value):
            return await packWithOption(value: value)
        case .valueWithOption(let value, let option):
            return await packWithOption(value: value, option: option)
        case .string(let value, let encoding):
            return packString(value: value, encoding: encoding)
        case .structure(let values):
            return await packStructure(values: values)
        }
    }

    private func packWithOption(value: any MessagePackableValue) async -> Result<Data, MessagePackError> {
        switch value {
        case is Int:
            return await packWithOption(value: value, option: .int_64)
        case is Int8:
            return await packWithOption(value: value, option: .int_8)
        case is Int16:
            return await packWithOption(value: value, option: .int_16)
        case is Int32:
            return await packWithOption(value: value, option: .int_32)
        case is Int64:
            return await packWithOption(value: value, option: .int_64)
        case is UInt:
            return await packWithOption(value: value, option: .uint_64)
        case is UInt8:
            return await packWithOption(value: value, option: .uint_8)
        case is UInt16:
            return await packWithOption(value: value, option: .uint_16)
        case is UInt32:
            return await packWithOption(value: value, option: .uint_32)
        case is UInt64:
            return await packWithOption(value: value, option: .uint_64)
        case is Float32:
            return await packWithOption(value: value, option: .float_32)
        case is Float64:
            return await packWithOption(value: value, option: .float_64)
        case is String:
            return packString(value: value, encoding: .utf8)
        case is Data:
            return await packWithOption(value: value, option: .bin_32)
        case is Array<any MessagePackableValue>:
            return await packWithOption(value: value, option: .array_32)
        case is Bool:
            return await packWithOption(value: value, option: self as! Bool ? .true : .false)
        // case is Dictionary<MesssagePackableValue, MessagePackable>: // ????
        //     break
        default:
            return .failure(.unknownType)
        }
    }

    private func packWithOption(
        value: any MessagePackableValue,
        option: MessagePackType
    ) -> Result<Data, MessagePackError> {
        switch option {
        case .positive_fixint:
            guard let value = value as? any FixedWidthInteger else {
                return .failure(.invalidData)
            }
            let byteArray = byteArray(from: value)
            guard let last = byteArray.last else {
                return .failure(.invalidData)
            }
            guard last <= MessagePackType.positive_fixint_max else {
                return .failure(.invalidData)
            }
            return .success(Data([last]))
        case .fixmap:
            break
        case .fixarray:
            break
        case .fixstr:
            return packString(value: value, encoding: .utf8, constraint: .fixstr)
        case .nil:
            return .success(Data([MessagePackType.nil.rawValue]))
        case .false:
            return .success(Data([MessagePackType.false.rawValue]))
        case .true:
            return .success(Data([MessagePackType.true.rawValue]))
        case .bin_8:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            return .success(Data([MessagePackType.bin_8.rawValue, UInt8(value.count)] + value))
        case .bin_16:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            return .success(Data([MessagePackType.bin_16.rawValue] + byteArray(from: UInt16(value.count)) + value))
        case .bin_32:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            return .success(Data([MessagePackType.bin_32.rawValue] + byteArray(from: UInt32(value.count)) + value))
        case .ext_8:
            break
        case .ext_16:
            break
        case .ext_32:
            break
        case .float_32:
            break
        case .float_64:
            break
        case .uint_8:
            return packInteger(value: value, byteAmount: 1, firstByte: MessagePackType.uint_8.rawValue)
        case .uint_16:
            return packInteger(value: value, byteAmount: 2, firstByte: MessagePackType.uint_16.rawValue)
        case .uint_32:
            return packInteger(value: value, byteAmount: 4, firstByte: MessagePackType.uint_32.rawValue)
        case .uint_64:
            return packInteger(value: value, byteAmount: 8, firstByte: MessagePackType.uint_64.rawValue)
        case .int_8:
            return packInteger(value: value, byteAmount: 1, firstByte: MessagePackType.int_8.rawValue)
        case .int_16:
            return packInteger(value: value, byteAmount: 2, firstByte: MessagePackType.int_16.rawValue)
        case .int_32:
            return packInteger(value: value, byteAmount: 4, firstByte: MessagePackType.int_32.rawValue)
        case .int_64:
            return packInteger(value: value, byteAmount: 8, firstByte: MessagePackType.int_64.rawValue)
        case .fixext_1:
            break
        case .fixext_2:
            break
        case .fixext_4:
            break
        case .fixext_8:
            break
        case .fixext_16:
            break
        case .str_8:
            return packString(value: value, encoding: .utf8, constraint: .str_8)
        case .str_16:
            return packString(value: value, encoding: .utf8, constraint: .str_16)
        case .str_32:
            return packString(value: value, encoding: .utf8, constraint: .str_32)
        case .array_16:
            break
        case .array_32:
            break
        case .map_16:
            break
        case .map_32:
            break
        case .negative_fixint:
            guard let value = value as? any FixedWidthInteger else {
                return .failure(.invalidData)
            }
            let byteArray = byteArray(from: value)
            guard var last = byteArray.last else {
                return .failure(.invalidData)
            }
            let valueRange = MessagePackType.negative_fixint.rawValue - MessagePackType.negative_fixint_max
            guard last <= valueRange else {
                return .failure(.invalidData)
            }
            last = last | MessagePackType.negative_fixint.rawValue
            return .success(Data([last]))
        }
        return .failure(.notImplemented)
    }

    private func byteArray<T: FixedWidthInteger>(
        from value: T
    ) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    private func packInteger(
        value: any MessagePackableValue,
        byteAmount: Int,
        firstByte: UInt8
    ) -> Result<Data, MessagePackError> {
        guard let value = value as? any FixedWidthInteger else {
            return .failure(.invalidData)
        }
        var byteArray = byteArray(from: value)
        constraintArray(&byteArray, with: byteAmount)
        byteArray.insert(firstByte, at: 0)
        return .success(Data(byteArray))
    }

    func packString(
        value: any MessagePackableValue,
        encoding: String.Encoding,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        guard let value = value as? String else {
            return .failure(.invalidData)
        }
        if value.isEmpty && constraint == nil {
            return .success(Data([MessagePackType.fixstr.rawValue]))
        }
        var byteArray = [UInt8]()
        guard let data = value.data(using: encoding) else {
            return .failure(.invalidData)
        }
        byteArray.append(contentsOf: data)
        if let constraint {
            switch constraint {
            case .fixstr:
                constraingStringArray(&byteArray, with: 31)
                byteArray.insert(MessagePackType.fixstr.rawValue | UInt8(byteArray.count), at: 0)
                return .success(Data(byteArray))
            case .str_8:
                constraingStringArray(&byteArray, with: Int(UInt8.max))
                byteArray.insert(MessagePackType.str_8.rawValue, at: 0)
                byteArray.insert(UInt8(byteArray.count - 1), at: 1)
                return .success(Data(byteArray))
            case .str_16:
                constraingStringArray(&byteArray, with: Int(UInt16.max))
                let countBytes = withUnsafeBytes(of: UInt16(byteArray.count), Array.init)
                byteArray.insert(MessagePackType.str_16.rawValue, at: 0)
                byteArray.insert(UInt8(countBytes[1]), at: 1)
                byteArray.insert(UInt8(countBytes[0]), at: 2)
                return .success(Data(byteArray))
            case .str_32:
                constraingStringArray(&byteArray, with: Int(UInt32.max))
                let countBytes = withUnsafeBytes(of: UInt32(byteArray.count), Array.init)
                byteArray.insert(MessagePackType.str_32.rawValue, at: 0)
                byteArray.insert(UInt8(countBytes[3]), at: 1)
                byteArray.insert(UInt8(countBytes[2]), at: 2)
                byteArray.insert(UInt8(countBytes[1]), at: 3)
                byteArray.insert(UInt8(countBytes[0]), at: 4)
                return .success(Data(byteArray))
            default:
                return .failure(.invalidData)
            }
        }
        if byteArray.count <= 31 {
            byteArray.insert(MessagePackType.fixstr.rawValue | UInt8(byteArray.count), at: 0)
            return .success(Data(byteArray))
        } else if byteArray.count <= UInt8.max {
            byteArray.insert(MessagePackType.str_8.rawValue, at: 0)
            byteArray.insert(UInt8(byteArray.count - 1), at: 1)
            return .success(Data(byteArray))
        } else if byteArray.count <= UInt16.max {
            let countBytes = withUnsafeBytes(of: UInt16(byteArray.count), Array.init)
            byteArray.insert(MessagePackType.str_16.rawValue, at: 0)
            byteArray.insert(UInt8(countBytes[1]), at: 1)
            byteArray.insert(UInt8(countBytes[0]), at: 2)
            return .success(Data(byteArray))
        } else if byteArray.count > UInt32.max {
            byteArray = Array(byteArray.prefix(upTo: Int(UInt32.max)))
        }
        let countBytes = withUnsafeBytes(of: UInt32(byteArray.count), Array.init)
        byteArray.insert(MessagePackType.str_32.rawValue, at: 0)
        byteArray.insert(UInt8(countBytes[3]), at: 1)
        byteArray.insert(UInt8(countBytes[2]), at: 2)
        byteArray.insert(UInt8(countBytes[1]), at: 3)
        byteArray.insert(UInt8(countBytes[0]), at: 4)
        return .success(Data(byteArray))
    }

    private func constraingStringArray(
        _ byteArray: inout [UInt8],
        with byteAmount: Int
    ) {
        if byteArray.count > byteAmount {
            byteArray = Array(byteArray.prefix(upTo: byteAmount))
        }
    }

    private func constraintArray(
        _ byteArray: inout [UInt8],
        with byteAmount: Int
    ) {
        if byteArray.count < byteAmount {
            let temp = [UInt8](repeating: 0, count: byteAmount - byteArray.count)
            byteArray.insert(contentsOf: temp, at: 0)
        } else if byteArray.count > byteAmount {
            byteArray = byteArray.suffix(byteAmount)
        }
    }

    private func packWithOption(
        value: any MessagePackableValue,
        option: MessagePackType
    ) async -> Result<Data, MessagePackError> {
        return .failure(.notImplemented)
    }

    private func packStructure(values: [MessagePackValue]) -> Result<Data, MessagePackError> {
        return .failure(.notImplemented)
    }

    private func packStructure(values: [MessagePackValue]) async -> Result<Data, MessagePackError> {
        return .failure(.notImplemented)
    }
}

public class MessagePackData {

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    public func unpack<T: MessagePackableValue>() -> Result<T, MessagePackError> {
        return unpack(as: T.self)
    }

    public func unpack<T: MessagePackableValue>(as type: T.Type) -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

    public func unpack<T: MessagePackableValue>() async -> Result<T, MessagePackError> {
        return await unpack(as: T.self)
    }

    public func unpack<T: MessagePackableValue>(as type: T.Type) async -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

}

public class MessagePacker {

}
