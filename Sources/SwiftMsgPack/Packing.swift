import Foundation

public enum MessagePackError: Error {
    case unknownType
    case invalidData
    case notImplemented
}

public enum MessagePackValue {
    case date(Date, format: MessagePackDateFormat = .timestamp_32)
    case value(any MessagePackable)
    case valueWithOption(any MessagePackable, option: MessagePackType)
    case string(String, encoding: String.Encoding = .utf8)
    case structure([MessagePackValue])
    case structureAsExt(id: UInt8, [MessagePackValue], constraint: MessagePackType? = nil)
}

public protocol MessagePackable {
    func packValue() -> MessagePackValue
}

public extension MessagePackable {

    func pack() -> Result<Data, MessagePackError> {
        let value = packValue()
        return pack(value: value)
    }

    private func pack(value: MessagePackValue) -> Result<Data, MessagePackError> {
        switch value {
        case .date(let value, let format):
            return MessagePacker.packDate(value: value, with: format)
        case .value(let value):
            return pack(value: value)
        case .valueWithOption(let value, let option):
            return packWithOption(value: value, option: option)
        case .string(let value, let encoding):
            return MessagePacker.packString(value: value, encoding: encoding)
        case .structure(let values):
            return packStructure(values: values)
        case .structureAsExt(let id, let values, let constraint):
            return packStructureAsExt(values: values, id: id, constraint: constraint)
        }
    }

    private func pack(value: any MessagePackable) -> Result<Data, MessagePackError> {
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
            return MessagePacker.packString(value: value, encoding: .utf8)
        case is Data:
            return packWithOption(value: value, option: .bin_32)
        case is Array<any MessagePackable>:
            return MessagePacker.packArray(value: value)
        case is Bool:
            return packWithOption(value: value, option: self as! Bool ? .true : .false)
        case is Dictionary<AnyHashable, any MessagePackable>:
            return MessagePacker.packDictionary(value: value)
        case is Date:
            return MessagePacker.packDate(value: value, with: .timestamp_32)
        default:
            return pack()
        }
    }

    @available(macOS 12.0, *)
    func pack() async -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
        case .date(let value, let format):
            return MessagePacker.packDate(value: value, with: format)
        case .value(let value):
            return pack(value: value)
        case .valueWithOption(let value, let option):
            return packWithOption(value: value, option: option)
        case .string(let value, let encoding):
            return MessagePacker.packString(value: value, encoding: encoding)
        case .structure(let values):
            return packStructure(values: values)
        case .structureAsExt(let id, let values, let constraint):
            return packStructureAsExt(values: values, id: id, constraint: constraint)
        }
    }

    private func packWithOption(
        value: any MessagePackable,
        option: MessagePackType
    ) -> Result<Data, MessagePackError> {
        switch option {
        case .positive_fixint:
            guard let value = value as? any FixedWidthInteger else {
                return .failure(.invalidData)
            }
            let byteArray = MessagePacker.byteArray(from: value)
            guard let last = byteArray.last else {
                return .failure(.invalidData)
            }
            guard last <= MessagePackType.positive_fixint_max else {
                return .failure(.invalidData)
            }
            return .success(Data([last]))
        case .fixmap:
            return MessagePacker.packDictionary(value: value, constraint: .fixmap)
        case .fixarray:
            return MessagePacker.packArray(value: value, constraint: .fixarray)
        case .fixstr:
            return MessagePacker.packString(value: value, encoding: .utf8, constraint: .fixstr)
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
            return .success(
                Data([MessagePackType.bin_16.rawValue] + MessagePacker.byteArray(from: UInt16(value.count)) + value)
            )
        case .bin_32:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            return .success(
                Data([MessagePackType.bin_32.rawValue] + MessagePacker.byteArray(from: UInt32(value.count)) + value)
            )
        case .ext_8:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count > UInt8.max {
                value = value.prefix(upTo: Int(UInt8.max))
            }
            return .success(Data([MessagePackType.ext_8.rawValue, UInt8(value.count)] + value))
        case .ext_16:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count > UInt16.max {
                value = value.prefix(upTo: Int(UInt16.max))
            }
            return .success(
                Data([MessagePackType.ext_16.rawValue] + MessagePacker.byteArray(from: UInt16(value.count)) + value)
            )
        case .ext_32:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count > UInt32.max {
                value = value.prefix(upTo: Int(UInt32.max))
            }
            return .success(
                Data([MessagePackType.ext_32.rawValue] + MessagePacker.byteArray(from: UInt32(value.count)) + value)
            )
        case .float_32:
            return MessagePacker.packFloat(value: value, constraint: .float_32)
        case .float_64:
            return MessagePacker.packFloat(value: value, constraint: .float_64)
        case .uint_8:
            return MessagePacker.packInteger(value: value, byteAmount: 1, firstByte: MessagePackType.uint_8.rawValue)
        case .uint_16:
            return MessagePacker.packInteger(value: value, byteAmount: 2, firstByte: MessagePackType.uint_16.rawValue)
        case .uint_32:
            return MessagePacker.packInteger(value: value, byteAmount: 4, firstByte: MessagePackType.uint_32.rawValue)
        case .uint_64:
            return MessagePacker.packInteger(value: value, byteAmount: 8, firstByte: MessagePackType.uint_64.rawValue)
        case .int_8:
            return MessagePacker.packInteger(value: value, byteAmount: 1, firstByte: MessagePackType.int_8.rawValue)
        case .int_16:
            return MessagePacker.packInteger(value: value, byteAmount: 2, firstByte: MessagePackType.int_16.rawValue)
        case .int_32:
            return MessagePacker.packInteger(value: value, byteAmount: 4, firstByte: MessagePackType.int_32.rawValue)
        case .int_64:
            return MessagePacker.packInteger(value: value, byteAmount: 8, firstByte: MessagePackType.int_64.rawValue)
        case .fixext_1:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count > 1 {
                value = value.prefix(upTo: 1)
            }
            return .success(Data([MessagePackType.fixext_1.rawValue, UInt8(value.count)] + value))
        case .fixext_2:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count < 2 {
                value = value + [0, 0]
            }
            if value.count > 2 {
                value = value.prefix(upTo: 2)
            }
            return .success(Data([MessagePackType.fixext_2.rawValue] + value))
        case .fixext_4:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count < 4 {
                value = value + Array(repeating: 0, count: 4)
            }
            if value.count > 4 {
                value = value.prefix(upTo: 4)
            }
            return .success(Data([MessagePackType.fixext_4.rawValue] + value))
        case .fixext_8:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count < 8 {
                value = value + Array(repeating: 0, count: 8)
            }
            if value.count > 8 {
                value = value.prefix(upTo: 8)
            }
            return .success(Data([MessagePackType.fixext_8.rawValue] + value))
        case .fixext_16:
            guard var value = value as? Data else {
                return .failure(.invalidData)
            }
            if value.count < 16 {
                value = value + Array(repeating: 0, count: 16)
            }
            if value.count > 16 {
                value = value.prefix(upTo: 16)
            }
            return .success(Data([MessagePackType.fixext_16.rawValue, UInt8(value.count)] + value))
        case .str_8:
            return MessagePacker.packString(value: value, encoding: .utf8, constraint: .str_8)
        case .str_16:
            return MessagePacker.packString(value: value, encoding: .utf8, constraint: .str_16)
        case .str_32:
            return MessagePacker.packString(value: value, encoding: .utf8, constraint: .str_32)
        case .array_16:
            return MessagePacker.packArray(value: value, constraint: .array_16)
        case .array_32:
            return MessagePacker.packArray(value: value, constraint: .array_32)
        case .map_16:
            return MessagePacker.packDictionary(value: value, constraint: .map_16)
        case .map_32:
            return MessagePacker.packDictionary(value: value, constraint: .map_32)
        case .negative_fixint:
            guard let value = value as? any FixedWidthInteger else {
                return .failure(.invalidData)
            }
            let byteArray = MessagePacker.byteArray(from: value)
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
    }

    private func packStructure(
        values: [MessagePackValue]
    ) -> Result<Data, MessagePackError> {
        var data = Data()
        for value in values {
            let result = pack(value: value)
            switch result {
            case .success(let valueData):
                data = data + valueData
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(data)
    }

    private func packStructureAsExt(
        values: [MessagePackValue],
        id: UInt8,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        var structData = Data()
        let result = packStructure(values: values)
        switch result {
        case .success(let data):
            structData = data
        case .failure(let error):
            return .failure(error)
        }
        if let constraint {
            switch constraint {
            case .ext_8:
                if structData.count > UInt8.max {
                    return .failure(.invalidData)
                }
                structData.insert(MessagePackType.ext_8.rawValue, at: 0)
                structData.insert(UInt8(structData.count), at: 1)
                structData.insert(id, at: 2)
                return .success(structData)
            case .ext_16:
                if structData.count > UInt16.max {
                    return .failure(.invalidData)
                }
                structData.insert(MessagePackType.ext_16.rawValue, at: 0)
                structData.insert(contentsOf: MessagePacker.byteArray(from: UInt16(structData.count)), at: 1)
                structData.insert(id, at: 3)
                return .success(structData)
            case .ext_32:
                if structData.count > UInt32.max {
                    return .failure(.invalidData)
                }
                structData.insert(MessagePackType.ext_32.rawValue, at: 0)
                structData.insert(contentsOf: MessagePacker.byteArray(from: UInt32(structData.count)), at: 1)
                structData.insert(id, at: 5)
                return .success(structData)
            default:
                return .failure(.invalidData)
            }
        }
        if structData.count <= UInt8.max {
            structData.insert(MessagePackType.ext_8.rawValue, at: 0)
            structData.insert(UInt8(structData.count), at: 1)
            structData.insert(id, at: 2)
            return .success(structData)
        } else if structData.count <= UInt16.max {
            structData.insert(MessagePackType.ext_16.rawValue, at: 0)
            structData.insert(contentsOf: MessagePacker.byteArray(from: UInt16(structData.count)), at: 1)
            structData.insert(id, at: 3)
            return .success(structData)
        } else if structData.count > UInt32.max {
            return .failure(.invalidData)
        }
        structData.insert(MessagePackType.ext_32.rawValue, at: 0)
        structData.insert(contentsOf: MessagePacker.byteArray(from: UInt32(structData.count)), at: 1)
        structData.insert(id, at: 5)
        return .success(structData)
    }

}

public class MessagePackData {

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    public func unpack<T: MessagePackable>() -> Result<T, MessagePackError> {
        return unpack(as: T.self)
    }

    public func unpack<T: MessagePackable>(as type: T.Type) -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

    @available(macOS 12.0, *)
    public func unpack<T: MessagePackable>() async -> Result<T, MessagePackError> {
        return await unpack(as: T.self)
    }

    @available(macOS 12.0, *)
    public func unpack<T: MessagePackable>(as type: T.Type) async -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

}

struct MessagePacker {

    static func packDate(
        value: any MessagePackable,
        with format: MessagePackDateFormat
    ) -> Result<Data, MessagePackError> {
        guard let value = value as? Date else {
            return .failure(.invalidData)
        }
        var byteArray = [UInt8]()
        let timeInterval = value.timeIntervalSince1970
        switch format {
        case .timestamp_32:
            if timeInterval > Double(UInt32.max) {
                return .failure(.invalidData)
            }
            let timestamp = UInt32(timeInterval)
            byteArray =
                [MessagePackType.fixext_4.rawValue, 0xff]
                + MessagePacker.byteArray(from: timestamp)
        case .timestamp_64:
            let timestamp = UInt32(timeInterval)
            let nanoseconds = UInt32((timeInterval - Double(timestamp)) * 1_000_000_000)
            byteArray =
                [MessagePackType.fixext_8.rawValue, 0xff]
                + MessagePacker.byteArray(from: nanoseconds) + MessagePacker.byteArray(from: timestamp)
        case .timestamp_96:
            let timestamp = UInt64(timeInterval)
            let nanoseconds = UInt32((timeInterval - Double(timestamp)) * 1_000_000_000)
            byteArray =
                [MessagePackType.ext_8.rawValue, 12, 0xff]
                + MessagePacker.byteArray(from: nanoseconds)
                + MessagePacker.byteArray(from: timestamp)
        }
        return .success(Data(byteArray))
    }

    static func packDictionary(
        value: any MessagePackable,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        let dict = value as! Dictionary<AnyHashable, any MessagePackable>
        guard dict.keys.allSatisfy({ $0.base is MessagePackable }) else {
            return .failure(.invalidData)
        }
        var dictData = Data()
        if let constraint {
            switch constraint {
            case .fixmap:
                if dict.count > MessagePackType.fixmap_max - MessagePackType.fixmap.rawValue {
                    return .failure(.invalidData)
                }
                dictData.append(MessagePackType.fixmap.rawValue + UInt8(dict.count))
            case .map_16:
                if dict.count > UInt16.max {
                    return .failure(.invalidData)
                }
                dictData.append(MessagePackType.map_16.rawValue)
                let count = byteArray(from: UInt16(dict.count))
                dictData.append(contentsOf: count)
            case .map_32:
                if dict.count > UInt32.max {
                    return .failure(.invalidData)
                }
                dictData.append(MessagePackType.map_32.rawValue)
                let count = byteArray(from: UInt32(dict.count))
                dictData.append(contentsOf: count)
            default:
                return .failure(.invalidData)
            }
        } else {
            if dict.count <= 15 {
                dictData.append(MessagePackType.fixmap.rawValue + UInt8(dict.count))
            } else if dict.count <= UInt16.max {
                dictData.append(MessagePackType.map_16.rawValue)
                let count = byteArray(from: UInt16(dict.count))
                dictData.append(contentsOf: count)
            } else if dict.count > UInt32.max {
                return .failure(.invalidData)
            } else {
                dictData.append(MessagePackType.map_32.rawValue)
                let count = byteArray(from: UInt32(dict.count))
                dictData.append(contentsOf: count)
            }
        }
        for (key, value) in dict {
            let keyResult = (key as! MessagePackable).pack()
            let valueResult = value.pack()
            switch keyResult {
            case .success(let keyData):
                dictData = dictData + keyData
            case .failure(let error):
                return .failure(error)
            }
            switch valueResult {
            case .success(let valueData):
                dictData = dictData + valueData
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(dictData)
    }

    static func packFloat(
        value: any MessagePackable,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        guard let value = value as? any FloatingPoint else {
            return .failure(.invalidData)
        }
        var byteArray = [UInt8]()
        if let constraint {
            switch constraint {
            case .float_32:
                guard let float = value as? Float32 else {
                    return .failure(.invalidData)
                }
                let floatBytes = withUnsafeBytes(of: float, Array.init)
                byteArray.append(MessagePackType.float_32.rawValue)
                byteArray.append(contentsOf: floatBytes)
            case .float_64:
                guard let double = value as? Float64 else {
                    return .failure(.invalidData)
                }
                let doubleBytes = withUnsafeBytes(of: double, Array.init)
                byteArray.append(MessagePackType.float_64.rawValue)
                byteArray.append(contentsOf: doubleBytes)
            default:
                return .failure(.invalidData)
            }
        } else {
            if let double = value as? Float64 {
                let doubleBytes = withUnsafeBytes(of: double, Array.init)
                byteArray.append(MessagePackType.float_64.rawValue)
                byteArray.append(contentsOf: doubleBytes)
            } else if let float = value as? Float32 {
                let floatBytes = withUnsafeBytes(of: float, Array.init)
                byteArray.append(MessagePackType.float_32.rawValue)
                byteArray.append(contentsOf: floatBytes)
            } else {
                return .failure(.invalidData)
            }
        }
        return .success(Data(byteArray))
    }

    static func packArray(
        value: any MessagePackable,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        guard var valueArr = value as? Array<any MessagePackable> else {
            return .failure(.invalidData)
        }
        var arrData = Data()
        if let constraint {
            switch constraint {
            case .fixarray:
                if valueArr.count > 15 {
                    valueArr = Array(valueArr.prefix(upTo: 15))
                }
                arrData.append(MessagePackType.fixarray.rawValue + UInt8(valueArr.count))
            case .array_16:
                if valueArr.count > UInt16.max {
                    valueArr = Array(valueArr.prefix(upTo: Int(UInt16.max)))
                }
                arrData.append(MessagePackType.array_16.rawValue)
                let count = byteArray(from: UInt16(valueArr.count))
                arrData.append(contentsOf: count)
            case .array_32:
                if valueArr.count > UInt32.max {
                    valueArr = Array(valueArr.prefix(upTo: Int(UInt32.max)))
                }
                arrData.append(MessagePackType.array_32.rawValue)
                let count = byteArray(from: UInt32(valueArr.count))
                arrData.append(contentsOf: count)
            default:
                return .failure(.invalidData)
            }
        } else {
            if valueArr.count <= 15 {
                arrData.append(MessagePackType.fixarray.rawValue + UInt8(valueArr.count))
            } else if valueArr.count <= UInt16.max {
                arrData.append(MessagePackType.array_16.rawValue)
                let count = byteArray(from: UInt16(valueArr.count))
                arrData.append(contentsOf: count)
            } else if valueArr.count <= UInt32.max {
                arrData.append(MessagePackType.array_32.rawValue)
                let count = byteArray(from: UInt32(valueArr.count))
                arrData.append(contentsOf: count)
            } else {
                arrData.append(MessagePackType.array_32.rawValue)
                valueArr = Array(valueArr.prefix(upTo: Int(UInt32.max)))
                let count = byteArray(from: UInt32(valueArr.count))
                arrData.append(contentsOf: count)
            }
        }
        for value in valueArr {
            let result = value.pack()
            switch result {
            case .success(let data):
                arrData = arrData + data
            case .failure(let error):
                return .failure(error)
            }
        }
        return .success(arrData)
    }

    static func byteArray<T: FixedWidthInteger>(
        from value: T
    ) -> [UInt8] {
        withUnsafeBytes(of: value.bigEndian, Array.init)
    }

    static func packInteger(
        value: any MessagePackable,
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

    static func constraintArray(
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

    static func packUInt8WithFixInt(
        value: UInt8,
        negative: Bool = false
    ) -> Result<Data, MessagePackError> {
        var value = value
        var byteArray = [UInt8]()
        if negative {
            if value > MessagePackType.negative_fixint_max - MessagePackType.negative_fixint.rawValue {
                value = MessagePackType.negative_fixint_max
            }
            byteArray.append(MessagePackType.negative_fixint.rawValue | value)
            return .success(Data(byteArray))
        }
        if value > MessagePackType.positive_fixint_max {
            value = MessagePackType.positive_fixint_max
        }
        byteArray.append(MessagePackType.positive_fixint.rawValue | value)
        return .success(Data(byteArray))
    }

    static func packString(
        value: any MessagePackable,
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

    static func constraingStringArray(
        _ byteArray: inout [UInt8],
        with byteAmount: Int
    ) {
        if byteArray.count > byteAmount {
            byteArray = Array(byteArray.prefix(upTo: byteAmount))
        }
    }
}
