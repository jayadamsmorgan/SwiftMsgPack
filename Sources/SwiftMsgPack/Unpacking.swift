import Foundation

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
