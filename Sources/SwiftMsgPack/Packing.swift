import Foundation

public enum MessagePackError: Error {
    case unknownType
    case invalidData
    case notImplemented
    case constraintOverflow
    case invalidConstraint

    case unpackUnknownByte
    case unpackIndexOutOfBounds
    case unpackMapCountNotEven
    case unpackMapKeyNotHashable
}

public enum MessagePackValue {
    case value(any MessagePackable)
    case valueWithOption(any MessagePackable, option: MessagePackType)
    case string(String, encoding: String.Encoding = .utf8)
    case structure([MessagePackValue])
    case structureAsExt(id: Int8, [MessagePackValue], constraint: MessagePackType? = nil)
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
            return MessagePacker.packDate(value: value)
        default:
            return .failure(.unknownType)
        }
    }

    @available(macOS 10.15.0, iOS 15.0, *)
    func pack() async -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
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
            guard value.count <= UInt8.max else {
                return .failure(.constraintOverflow)
            }
            return .success(Data([MessagePackType.bin_8.rawValue, UInt8(value.count)] + value))
        case .bin_16:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count <= UInt16.max else {
                return .failure(.constraintOverflow)
            }
            return .success(
                Data([MessagePackType.bin_16.rawValue] + MessagePacker.byteArray(from: UInt16(value.count)) + value)
            )
        case .bin_32:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count <= UInt32.max else {
                return .failure(.constraintOverflow)
            }
            return .success(
                Data([MessagePackType.bin_32.rawValue] + MessagePacker.byteArray(from: UInt32(value.count)) + value)
            )
        case .ext_8:
            switch value {
            case let value as Data:
                guard value.count <= UInt8.max else {
                    return .failure(.constraintOverflow)
                }
                return .success(Data([MessagePackType.ext_8.rawValue, UInt8(value.count)] + value))
            case let value as Date:
                return MessagePacker.packDate(value: value, constraint: .ext_8)
            default:
                return .failure(.invalidData)
            }
        case .ext_16:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count <= UInt16.max else {
                return .failure(.constraintOverflow)
            }
            return .success(
                Data([MessagePackType.ext_16.rawValue] + MessagePacker.byteArray(from: UInt16(value.count)) + value)
            )
        case .ext_32:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count <= UInt32.max else {
                return .failure(.constraintOverflow)
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
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count == 1 else {
                return .failure(.constraintOverflow)
            }
            return .success(Data([MessagePackType.fixext_1.rawValue, UInt8(value.count)] + value))
        case .fixext_2:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count == 2 else {
                return .failure(.constraintOverflow)
            }
            return .success(Data([MessagePackType.fixext_2.rawValue] + value))
        case .fixext_4:
            switch value {
            case let value as Data:
                guard value.count == 4 else {
                    return .failure(.constraintOverflow)
                }
                return .success(Data([MessagePackType.fixext_4.rawValue] + value))
            case let value as Date:
                return MessagePacker.packDate(value: value, constraint: .fixext_4)
            default:
                return .failure(.invalidData)
            }
        case .fixext_8:
            switch value {
            case let value as Data:
                guard value.count == 8 else {
                    return .failure(.constraintOverflow)
                }
                return .success(Data([MessagePackType.fixext_8.rawValue] + value))
            case let value as Date:
                return MessagePacker.packDate(value: value, constraint: .fixext_8)
            default:
                return .failure(.invalidData)
            }
        case .fixext_16:
            guard let value = value as? Data else {
                return .failure(.invalidData)
            }
            guard value.count == 16 else {
                return .failure(.constraintOverflow)
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
                return .failure(.constraintOverflow)
            }
            let valueRange = MessagePackType.negative_fixint.rawValue - MessagePackType.negative_fixint_max
            guard last <= valueRange else {
                return .failure(.constraintOverflow)
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
        id: Int8,
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
                    return .failure(.constraintOverflow)
                }
                structData.insert(MessagePackType.ext_8.rawValue, at: 0)
                structData.insert(UInt8(structData.count), at: 1)
                structData.insert(UInt8(id - Int8.min), at: 2)
                return .success(structData)
            case .ext_16:
                if structData.count > UInt16.max {
                    return .failure(.constraintOverflow)
                }
                structData.insert(MessagePackType.ext_16.rawValue, at: 0)
                structData.insert(contentsOf: MessagePacker.byteArray(from: UInt16(structData.count)), at: 1)
                structData.insert(UInt8(id - Int8.min), at: 3)
                return .success(structData)
            case .ext_32:
                if structData.count > UInt32.max {
                    return .failure(.constraintOverflow)
                }
                structData.insert(MessagePackType.ext_32.rawValue, at: 0)
                structData.insert(contentsOf: MessagePacker.byteArray(from: UInt32(structData.count)), at: 1)
                structData.insert(UInt8(id - Int8.min), at: 5)
                return .success(structData)
            default:
                return .failure(.invalidConstraint)
            }
        }
        if structData.count <= UInt8.max {
            structData.insert(MessagePackType.ext_8.rawValue, at: 0)
            structData.insert(UInt8(structData.count), at: 1)
            structData.insert(UInt8(id - Int8.min), at: 2)
            return .success(structData)
        } else if structData.count <= UInt16.max {
            structData.insert(MessagePackType.ext_16.rawValue, at: 0)
            structData.insert(contentsOf: MessagePacker.byteArray(from: UInt16(structData.count)), at: 1)
            structData.insert(UInt8(id - Int8.min), at: 3)
            return .success(structData)
        } else if structData.count > UInt32.max {
            return .failure(.constraintOverflow)
        }
        structData.insert(MessagePackType.ext_32.rawValue, at: 0)
        structData.insert(contentsOf: MessagePacker.byteArray(from: UInt32(structData.count)), at: 1)
        structData.insert(UInt8(id - Int8.min), at: 5)
        return .success(structData)
    }

}

public class MessagePackData {

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    @available(macOS 10.15.0, iOS 15.0, *)
    public func unpack() async -> Result<[Any], MessagePackError> {
        return unpackSync()
    }

    public func unpack() -> Result<[Any], MessagePackError> {
        return unpackSync()
    }

    private func unpackSync() -> Result<[Any], MessagePackError> {
        var result: [Any] = []
        for var i in 0..<data.count {
            let (firstByte, fixPayload) = handleFixValues(byte: data[i])
            guard let byte = MessagePackType(rawValue: firstByte) else {
                return .failure(.unpackUnknownByte)
            }
            switch byte {
            case .positive_fixint:
                result.append(fixPayload)
            case .fixmap:
                let mapLength = Int(fixPayload)
                let mapResult = unpackMap(mapLength: mapLength, i: i)
                switch mapResult {
                case .success(let map):
                    result.append(map)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + mapLength
            case .fixarray:
                let arrayLength = Int(fixPayload)
                let arrayResult = unpackArray(arrayLength: arrayLength, i: i)
                switch arrayResult {
                case .success(let array):
                    result.append(array)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + arrayLength
            case .fixstr:
                break
            case .`nil`:
                break
            case .`false`:
                break
            case .`true`:
                break
            case .bin_8:
                break
            case .bin_16:
                break
            case .bin_32:
                break
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
                break
            case .uint_16:
                break
            case .uint_32:
                break
            case .uint_64:
                break
            case .int_8:
                break
            case .int_16:
                break
            case .int_32:
                break
            case .int_64:
                break
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
                break
            case .str_16:
                break
            case .str_32:
                break
            case .array_16:
                break
            case .array_32:
                break
            case .map_16:
                break
            case .map_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
            case .negative_fixint:
                let value = -Int8(fixPayload)
                result.append(value)
            }
        }
        return .success(result)
    }

    private func messagePackDataFromBytes(
        data: Data,
        index i: Int,
        arrayLength: Int
    ) -> Result<MessagePackData, MessagePackError> {
        let arrayFirstIndex = i + 1
        let arrayLastIndex = arrayFirstIndex + arrayLength
        guard arrayLength + i + 1 < data.count else {
            return .failure(.unpackIndexOutOfBounds)
        }
        let arrData = data[arrayFirstIndex...arrayLastIndex]
        return .success(MessagePackData(data: arrData))
    }

    private func unpackArray(
        arrayLength: Int,
        i: Int
    ) -> Result<[Any], MessagePackError> {
        let msgPackDataResult = messagePackDataFromBytes(
            data: data,
            index: i,
            arrayLength: arrayLength
        )
        switch msgPackDataResult {
        case .success(let msgPackData):
            return msgPackData.unpackSync()
        case .failure(let error):
            return .failure(error)
        }
    }

    private func unpackMap(
        mapLength: Int,
        i: Int
    ) -> Result<Dictionary<AnyHashable, Any>, MessagePackError> {
        let msgPackDataResult = messagePackDataFromBytes(
            data: data,
            index: i,
            arrayLength: mapLength * 2
        )
        switch msgPackDataResult {
        case .success(let msgPackData):
            let mapResult = msgPackData.unpackSync()
            var map = [AnyHashable: Any]()
            switch mapResult {
            case .success(let array):
                guard array.count % 2 == 0 else {
                    return .failure(.unpackMapCountNotEven)
                }
                for i in stride(from: 0, to: array.count, by: 2) {
                    let key = array[i]
                    let value = array[i + 1]
                    guard let key = key as? AnyHashable else {
                        return .failure(.unpackMapKeyNotHashable)
                    }
                    map[key] = value
                }
                return .success(map)
            case .failure(let error):
                return .failure(error)
            }
        case .failure(let error):
            return .failure(error)
        }
    }

    private func handleFixValues(byte: UInt8) -> (firstByte: UInt8, fixPayload: UInt8) {
        var firstByte: UInt8 = byte
        var fixPayload: UInt8 = 0
        if byte > MessagePackType.positive_fixint.rawValue && byte < MessagePackType.fixmap.rawValue {
            firstByte = MessagePackType.positive_fixint.rawValue
            fixPayload = byte - firstByte
        } else if byte > MessagePackType.fixmap.rawValue && byte < MessagePackType.fixarray.rawValue {
            firstByte = MessagePackType.fixmap.rawValue
            fixPayload = byte - firstByte
        } else if byte > MessagePackType.fixarray.rawValue && byte < MessagePackType.fixstr.rawValue {
            firstByte = MessagePackType.fixarray.rawValue
            fixPayload = byte - firstByte
        } else if byte > MessagePackType.fixstr.rawValue && byte < MessagePackType.nil.rawValue {
            firstByte = MessagePackType.fixstr.rawValue
            fixPayload = byte - firstByte
        } else if byte > MessagePackType.negative_fixint.rawValue
            && byte <= MessagePackType.negative_fixint_max
        {
            firstByte = MessagePackType.negative_fixint.rawValue
            fixPayload = byte - firstByte
        }
        return (firstByte, fixPayload)
    }

}

struct MessagePacker {

    static func packDate(
        value: any MessagePackable,
        constraint: MessagePackType? = nil
    ) -> Result<Data, MessagePackError> {
        guard let value = value as? Date else {
            return .failure(.invalidData)
        }
        var byteArray = [UInt8]()
        let timeInterval = value.timeIntervalSince1970
        let seconds = UInt64(timeInterval)
        let nanoseconds = UInt64((timeInterval - Double(seconds)) * 1_000_000_000)
        if let constraint {
            switch constraint {
            case .ext_8:
                byteArray =
                    [MessagePackType.ext_8.rawValue, 12, UInt8(-1 - Int8.min)]
                    + MessagePacker.byteArray(from: UInt32(nanoseconds))
                    + MessagePacker.byteArray(from: seconds)
                return .success(Data(byteArray))
            case .fixext_4:
                let data: UInt64 = (nanoseconds << 34) | seconds
                byteArray =
                    [MessagePackType.fixext_4.rawValue, UInt8(-1 - Int8.min)]
                    + MessagePacker.byteArray(from: UInt32(data))
                return .success(Data(byteArray))
            case .fixext_8:
                let data: UInt64 = (nanoseconds << 34) | seconds
                byteArray =
                    [MessagePackType.fixext_8.rawValue, UInt8(-1 - Int8.min)]
                    + MessagePacker.byteArray(from: data)
                return .success(Data(byteArray))
            default:
                return .failure(.invalidConstraint)
            }
        }
        if (seconds >> 34) != 0 {  //timestamp 96
            byteArray =
                [MessagePackType.ext_8.rawValue, 12, UInt8(-1 - Int8.min)]
                + MessagePacker.byteArray(from: UInt32(nanoseconds))
                + MessagePacker.byteArray(from: seconds)
            return .success(Data(byteArray))
        }
        let data: UInt64 = (nanoseconds << 34) | seconds
        if data <= UInt32.max {  // timestamp 32
            byteArray =
                [MessagePackType.fixext_4.rawValue, UInt8(-1 - Int8.min)]
                + MessagePacker.byteArray(from: UInt32(data))
            return .success(Data(byteArray))
        } else {  // timestamp 64
            byteArray =
                [MessagePackType.fixext_8.rawValue, UInt8(-1 - Int8.min)]
                + MessagePacker.byteArray(from: data)
            return .success(Data(byteArray))
        }
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
                    return .failure(.constraintOverflow)
                }
                dictData.append(MessagePackType.fixmap.rawValue + UInt8(dict.count))
            case .map_16:
                if dict.count > UInt16.max {
                    return .failure(.constraintOverflow)
                }
                dictData.append(MessagePackType.map_16.rawValue)
                let count = byteArray(from: UInt16(dict.count))
                dictData.append(contentsOf: count)
            case .map_32:
                if dict.count > UInt32.max {
                    return .failure(.constraintOverflow)
                }
                dictData.append(MessagePackType.map_32.rawValue)
                let count = byteArray(from: UInt32(dict.count))
                dictData.append(contentsOf: count)
            default:
                return .failure(.invalidConstraint)
            }
        } else {
            if dict.count <= 15 {
                dictData.append(MessagePackType.fixmap.rawValue + UInt8(dict.count))
            } else if dict.count <= UInt16.max {
                dictData.append(MessagePackType.map_16.rawValue)
                let count = byteArray(from: UInt16(dict.count))
                dictData.append(contentsOf: count)
            } else if dict.count > UInt32.max {
                return .failure(.constraintOverflow)
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
        guard let valueArr = value as? Array<any MessagePackable> else {
            return .failure(.invalidData)
        }
        var arrData = Data()
        if let constraint {
            switch constraint {
            case .fixarray:
                if valueArr.count > 15 {
                    return .failure(.constraintOverflow)
                }
                arrData.append(MessagePackType.fixarray.rawValue + UInt8(valueArr.count))
            case .array_16:
                if valueArr.count > UInt16.max {
                    return .failure(.constraintOverflow)
                }
                arrData.append(MessagePackType.array_16.rawValue)
                let count = byteArray(from: UInt16(valueArr.count))
                arrData.append(contentsOf: count)
            case .array_32:
                if valueArr.count > UInt32.max {
                    return .failure(.constraintOverflow)
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
                return .failure(.constraintOverflow)
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
        if byteArray.count < byteAmount {
            let temp = [UInt8](repeating: 0, count: byteAmount - byteArray.count)
            byteArray.insert(contentsOf: temp, at: 0)
        } else if byteArray.count > byteAmount {
            byteArray = byteArray.suffix(byteAmount)  // Not sure
        }
        byteArray.insert(firstByte, at: 0)
        return .success(Data(byteArray))
    }

    static func packUInt8WithFixInt(
        value: UInt8,
        negative: Bool = false
    ) -> Result<Data, MessagePackError> {
        var byteArray = [UInt8]()
        if negative {
            if value > MessagePackType.negative_fixint_max - MessagePackType.negative_fixint.rawValue {
                return .failure(.constraintOverflow)
            }
            byteArray.append(MessagePackType.negative_fixint.rawValue | value)
            return .success(Data(byteArray))
        }
        if value > MessagePackType.positive_fixint_max {
            return .failure(.constraintOverflow)
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
                if byteArray.count > 31 {
                    return .failure(.constraintOverflow)
                }
                byteArray.insert(MessagePackType.fixstr.rawValue | UInt8(byteArray.count), at: 0)
                return .success(Data(byteArray))
            case .str_8:
                if byteArray.count > UInt8.max {
                    return .failure(.constraintOverflow)
                }
                byteArray.insert(MessagePackType.str_8.rawValue, at: 0)
                byteArray.insert(UInt8(byteArray.count - 1), at: 1)
                return .success(Data(byteArray))
            case .str_16:
                if byteArray.count > UInt16.max {
                    return .failure(.constraintOverflow)
                }
                byteArray.insert(MessagePackType.str_16.rawValue, at: 0)
                byteArray.insert(contentsOf: MessagePacker.byteArray(from: UInt16(byteArray.count - 1)), at: 1)
                return .success(Data(byteArray))
            case .str_32:
                if byteArray.count > UInt32.max {
                    return .failure(.constraintOverflow)
                }
                byteArray.insert(MessagePackType.str_32.rawValue, at: 0)
                byteArray.insert(contentsOf: MessagePacker.byteArray(from: UInt32(byteArray.count - 1)), at: 1)
                return .success(Data(byteArray))
            default:
                return .failure(.invalidConstraint)
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
            byteArray.insert(MessagePackType.str_16.rawValue, at: 0)
            byteArray.insert(contentsOf: MessagePacker.byteArray(from: UInt16(byteArray.count - 1)), at: 1)
            return .success(Data(byteArray))
        } else if byteArray.count > UInt32.max {
            return .failure(.constraintOverflow)
        }
        byteArray.insert(MessagePackType.str_32.rawValue, at: 0)
        byteArray.insert(contentsOf: MessagePacker.byteArray(from: UInt32(byteArray.count - 1)), at: 1)
        return .success(Data(byteArray))
    }
}
