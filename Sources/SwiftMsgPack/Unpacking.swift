import Foundation

public class MessagePackData {

    public var data: Data

    fileprivate var i: Int = 0

    public init(data: Data) {
        self.data = data
    }

    @available(macOS 10.15.0, iOS 15.0, *)
    public func unpack() async -> Result<[Any?], MessagePackError> {
        return unpack(itemAmount: nil)
    }

    public func unpack() -> Result<[Any?], MessagePackError> {
        return unpack(itemAmount: nil)
    }

    private func unpack(itemAmount: Int? = nil) -> Result<[Any?], MessagePackError> {
        var result: [Any?] = []
        while i < data.count {
            let (firstByte, fixPayload) = handleFixValues(byte: data[i])
            guard let byte = MessagePackType(rawValue: firstByte) else {
                return .failure(.unpackUnknownByte)
            }
            switch byte {
            case .positive_fixint:
                result.append(fixPayload)
            case .fixmap:
                let mapLength = Int(fixPayload)
                i += 1
                let mapResult = unpackMap(mapLength: mapLength)
                switch mapResult {
                case .success(let map):
                    result.append(map)
                case .failure(let error):
                    return .failure(error)
                }
            case .fixarray:
                let arrayLength = Int(fixPayload)
                i += 1
                let arrayResult = unpackArray(arrayLength: arrayLength)
                switch arrayResult {
                case .success(let array):
                    result.append(array)
                case .failure(let error):
                    return .failure(error)
                }
            case .fixstr:
                let stringLength = Int(fixPayload)
                i += 1
                let stringResult = unpackString(stringLength: stringLength)
                switch stringResult {
                case .success(let str):
                    result.append(str)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + stringLength - 1
            case .nil:
                result.append(nil)
            case .false:
                result.append(false)
            case .true:
                result.append(true)
            case .bin_8:
                guard i + 1 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let binLength: UInt8 = intFromBigEndianBytes(data[i + 1...i + 1]) else {
                    return .failure(.unpackIntError)
                }
                guard i + 1 + Int(binLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let binData = Data(data[i + 2...i + 1 + Int(binLength)])
                result.append(binData)
                i = i + Int(binLength) + 1
            case .bin_16:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let binLength: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                guard i + 2 + Int(binLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let binData = Data(data[i + 3...i + 2 + Int(binLength)])
                result.append(binData)
                i = i + Int(binLength) + 2
            case .bin_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let binLength: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                guard i + 4 + Int(binLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let binData = Data(data[i + 5...i + 4 + Int(binLength)])
                result.append(binData)
                i = i + Int(binLength) + 4
            case .ext_8:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let dataLength: UInt8 = data[i + 1]
                guard i + 2 + Int(dataLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 2]) + Int(Int8.min))
                if type == -1 {
                    guard dataLength != 0 else {
                        return .failure(.unpackDateError)
                    }
                    let extData = Data(data[i + 3...i + 2 + Int(dataLength)])
                    let unpackResult = unpackDate(bytes: Data(extData))
                    switch unpackResult {
                    case .success(let date):
                        result.append(date)
                    case .failure(let error):
                        return .failure(error)
                    }
                } else {
                    if dataLength == 0 {
                        result.append(Ext(type: type, data: Data()))
                    } else {
                        let extData = Data(data[i + 3...i + 2 + Int(dataLength)])
                        result.append(Ext(type: type, data: extData))
                    }
                }
                i = i + Int(dataLength) + 2
            case .ext_16:
                guard i + 3 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let dataLength: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                guard i + 3 + Int(dataLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let extData = Data(data[i + 4...i + 3 + Int(dataLength)])
                let type: Int8 = Int8(Int(data[i + 3]) + Int(Int8.min))
                result.append(Ext(type: type, data: extData))
                i = i + Int(dataLength) + 3
            case .ext_32:
                guard i + 5 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let dataLength: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                guard i + 5 + Int(dataLength) < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let extData = Data(data[i + 6...i + 5 + Int(dataLength)])
                let type: Int8 = Int8(Int(data[i + 5]) + Int(Int8.min))
                result.append(Ext(type: type, data: extData))
                i = i + Int(dataLength) + 5
            case .float_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let bitPattern: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                result.append(Float32(bitPattern: bitPattern.bigEndian))
                i = i + 4
            case .float_64:
                guard i + 8 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let bitPattern: UInt64 = intFromBigEndianBytes(data[i + 1...i + 8]) else {
                    return .failure(.unpackIntError)
                }
                result.append(Float64(bitPattern: bitPattern.bigEndian))
                i = i + 8
            case .uint_8:
                guard i + 1 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: UInt8 = intFromBigEndianBytes(data[i + 1...i + 1]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 1
            case .uint_16:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 2
            case .uint_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 4
            case .uint_64:
                guard i + 8 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: UInt64 = intFromBigEndianBytes(data[i + 1...i + 8]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 8
            case .int_8:
                guard i + 1 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: Int8 = intFromBigEndianBytes(data[i + 1...i + 1]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 1
            case .int_16:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: Int16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 2
            case .int_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: Int32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 4
            case .int_64:
                guard i + 8 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let value: Int64 = intFromBigEndianBytes(data[i + 1...i + 8]) else {
                    return .failure(.unpackIntError)
                }
                result.append(value)
                i = i + 8
            case .fixext_1:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 1]) + Int(Int8.min))
                result.append(Ext(type: type, data: Data(data[i + 2...i + 2])))
                i = i + 2
            case .fixext_2:
                guard i + 3 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 1]) + Int(Int8.min))
                result.append(Ext(type: type, data: Data(data[i + 2...i + 3])))
                i = i + 3
            case .fixext_4:
                guard i + 5 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 1]) + Int(Int8.min))
                if type == -1 {
                    let unpackResult = unpackDate(bytes: Data(data[i + 2...i + 5]))
                    switch unpackResult {
                    case .success(let date):
                        result.append(date)
                    case .failure(let error):
                        return .failure(error)
                    }
                } else {
                    result.append(Ext(type: type, data: Data(data[i + 2...i + 5])))
                }
                i = i + 5
            case .fixext_8:
                guard i + 9 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 1]) + Int(Int8.min))
                if type == -1 {
                    let unpackResult = unpackDate(bytes: Data(data[i + 2...i + 9]))
                    switch unpackResult {
                    case .success(let date):
                        result.append(date)
                    case .failure(let error):
                        return .failure(error)
                    }
                } else {
                    result.append(Ext(type: type, data: Data(data[i + 2...i + 9])))
                }
                i = i + 9
            case .fixext_16:
                guard i + 17 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                let type: Int8 = Int8(Int(data[i + 1]) + Int(Int8.min))
                result.append(Ext(type: type, data: Data(data[i + 2...i + 17])))
                i = i + 17
            case .str_8:
                guard i + 1 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                i += 1
                guard let stringLength: UInt8 = intFromBigEndianBytes(data[i...i]) else {
                    return .failure(.unpackIntError)
                }
                i += 1
                let stringResult = unpackString(stringLength: Int(stringLength))
                switch stringResult {
                case .success(let str):
                    result.append(str)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + Int(stringLength) - 1
            case .str_16:
                guard i + 2 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let stringLength: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                i += 3
                let stringResult = unpackString(stringLength: Int(stringLength))
                switch stringResult {
                case .success(let str):
                    result.append(str)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + Int(stringLength) - 1
            case .str_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let stringLength: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                i += 5
                let stringResult = unpackString(stringLength: Int(stringLength))
                switch stringResult {
                case .success(let str):
                    result.append(str)
                case .failure(let error):
                    return .failure(error)
                }
                i = i + Int(stringLength) - 1
            case .array_16:
                guard let arrayLength: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                i = i + 3
                let arrayResult = unpackArray(arrayLength: Int(arrayLength))
                switch arrayResult {
                case .success(let array):
                    result.append(array)
                case .failure(let error):
                    return .failure(error)
                }
            case .array_32:
                guard let arrayLength: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                i = i + 5
                let arrayResult = unpackArray(arrayLength: Int(arrayLength))
                switch arrayResult {
                case .success(let array):
                    result.append(array)
                case .failure(let error):
                    return .failure(error)
                }
            case .map_16:
                guard let mapLength: UInt16 = intFromBigEndianBytes(data[i + 1...i + 2]) else {
                    return .failure(.unpackIntError)
                }
                i = i + 3
                let mapResult = unpackMap(mapLength: Int(mapLength))
                switch mapResult {
                case .success(let map):
                    result.append(map)
                case .failure(let error):
                    return .failure(error)
                }
            case .map_32:
                guard i + 4 < data.count else {
                    return .failure(.unpackIndexOutOfBounds)
                }
                guard let mapLength: UInt32 = intFromBigEndianBytes(data[i + 1...i + 4]) else {
                    return .failure(.unpackIntError)
                }
                i = i + 5
                let mapResult = unpackMap(mapLength: Int(mapLength))
                switch mapResult {
                case .success(let map):
                    result.append(map)
                case .failure(let error):
                    return .failure(error)
                }
            case .negative_fixint:
                let value = -Int8(fixPayload)
                result.append(value)
            }
            if let itemAmount = itemAmount, result.count == itemAmount {
                return .success(result)
            }
            i += 1
        }
        guard i == data.count else {
            return .failure(.unpackIndexOutOfBounds)
        }
        i = 0
        return .success(result)
    }

    private func unpackMap(
        mapLength: Int
    ) -> Result<Dictionary<AnyHashable, Any?>, MessagePackError> {
        let arrayResult = unpackArray(arrayLength: mapLength * 2)
        var dict = [AnyHashable: Any?]()
        switch arrayResult {
        case .success(let arr):
            var x = 0
            while x < arr.count {
                guard x + 1 < arr.count else {
                    return .failure(.unpackMapCountNotEven)
                }
                dict[arr[x] as! AnyHashable] = arr[x + 1]
                x += 2
            }
        case .failure(let error):
            return .failure(error)
        }
        return .success(dict)
    }

    private func unpackArray(arrayLength: Int) -> Result<[Any?], MessagePackError> {
        guard arrayLength > 0 else {
            return .success([])
        }
        return unpack(itemAmount: arrayLength)
    }

    private func unpackDate(bytes: Data) -> Result<Date, MessagePackError> {
        if bytes.count == 4 {
            guard let seconds: UInt32 = intFromBigEndianBytes(bytes) else {
                return .failure(.unpackIntError)
            }
            return .success(Date(timeIntervalSince1970: Double(seconds)))
        } else if bytes.count == 8 {
            guard let payload: UInt64 = intFromBigEndianBytes(bytes) else {
                return .failure(.unpackIntError)
            }
            let nanoPayload = payload.bigEndian >> 34
            let nano = Double(nanoPayload) / 1_000_000_000
            let secondsPayload = payload.bigEndian & 0x00000003ffffffff
            let seconds = Double(secondsPayload)
            let timeInterval = nano + seconds
            return .success(Date(timeIntervalSince1970: timeInterval))
        } else if bytes.count == 12 {
            guard let nano: UInt32 = intFromBigEndianBytes(bytes[0...3]) else {
                return .failure(.unpackIntError)
            }
            guard let seconds: UInt64 = intFromBigEndianBytes(bytes[4...11]) else {
                return .failure(.unpackIntError)
            }
            let timeInterval = Double(seconds) + Double(nano) / 1_000_000_000
            return .success(Date(timeIntervalSince1970: timeInterval))
        } else {
            return .failure(.unpackDateError)
        }
    }

    private func unpackString(
        stringLength: Int,
        encoding: String.Encoding = .utf8
    ) -> Result<String, MessagePackError> {
        guard stringLength != 0 else {
            return .success("")
        }
        guard i + stringLength <= data.count else {
            return .failure(.unpackIndexOutOfBounds)
        }
        let strData = Data(data[i..<i + stringLength])
        guard let str = String(data: strData, encoding: encoding) else {
            return .failure(.unpackStringError)
        }
        return .success(str)
    }

    private func intFromBigEndianBytes<T: FixedWidthInteger>(_ bytes: Data) -> T? {
        let size = MemoryLayout<T>.size
        var value: T = 0
        guard bytes.count == size else {
            return nil
        }
        value = Data(bytes).withUnsafeBytes {
            $0.load(as: T.self)
        }
        return T(bigEndian: value)
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
