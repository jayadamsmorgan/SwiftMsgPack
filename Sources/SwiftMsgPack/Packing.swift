import Foundation

public enum MessagePackError: Error {
    case unknownType
    case invalidData
    case notImplemented
}

public enum MessagePackValue {
    case value(any MessagePackable)
    case valueWithOption(any MessagePackable, option: MessagePackType)
    case structure([MessagePackValue])
}

public protocol MessagePackable {
    func packValue() -> MessagePackValue
}

public extension MessagePackable {

    func pack() throws -> Data {
        return try pack().get()
    }

    func pack() -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
        case .value(let value):
            if #available(macOS 11.0, *) {
                switch value {
                case is Int:
                    #if __LP64__
                    return packWithOption(option: .int_64)
                    #else
                    return packWithOption(option: .int_32)
                    #endif
                case is Int8:
                    return packWithOption(option: .int_8)
                case is Int16:
                    return packWithOption(option: .int_16)
                case is Int32:
                    return packWithOption(option: .int_32)
                case is Int64:
                    return packWithOption(option: .int_64)
                case is UInt:
                    #if __LP64__
                    return packWithOption(option: .uint_64)
                    #else
                    return packWithOption(option: .uint_32)
                    #endif
                case is UInt8:
                    return packWithOption(option: .uint_8)
                case is UInt16:
                    return packWithOption(option: .uint_16)
                case is UInt32:
                    return packWithOption(option: .uint_32)
                case is UInt64:
                    return packWithOption(option: .uint_64)
                case is Float16:
                    return packWithOption(option: .float_32)
                case is Float32:
                    return packWithOption(option: .float_32)
                case is Float64:
                    return packWithOption(option: .float_64)
                case is String:
                    return packWithOption(option: .str_32)
                case is Data:
                    return packWithOption(option: .bin_32)
                case is Array<any MessagePackable>:
                    return packWithOption(option: .array_32)
                case is Bool:
                    return packWithOption(option: self as! Bool ? .true : .false)
                // case is Dictionary<MessagePackable, MessagePackable>: // ????
                //     break
                default:
                    return .failure(.unknownType)
                }
            }
            break
        case .valueWithOption(let value, let option):
            break
        case .structure(let values):
            break
        }

        return .failure(.notImplemented)
    }

    private func packWithOption(option: MessagePackType) -> Result<Data, MessagePackError> {
        return .failure(.notImplemented)
    }
}

public class MessagePackData {

    public var data: Data

    public init(data: Data) {
        self.data = data
    }

    public func unpack<T: MessagePackable>() throws -> T {
        return try unpack(as: T.self)
    }

    public func unpack<T: MessagePackable>() -> Result<T, MessagePackError> {
        return unpack(as: T.self)
    }

    public func unpack<T: MessagePackable>(as type: T.Type) throws -> T {
        return try unpack(as: T.self).get()
    }

    public func unpack<T: MessagePackable>(as type: T.Type) -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

    public func unpack<T: MessagePackable>() async throws -> T {
        return try await unpack(as: T.self)
    }

    public func unpack<T: MessagePackable>() async -> Result<T, MessagePackError> {
        return await unpack(as: T.self)
    }

    public func unpack<T: MessagePackable>(as type: T.Type) async throws -> T {
        return try await unpack(as: T.self).get()
    }

    public func unpack<T: MessagePackable>(as type: T.Type) async -> Result<T, MessagePackError> {
        return .failure(.notImplemented)
    }

}

public class MessagePacker {

}
