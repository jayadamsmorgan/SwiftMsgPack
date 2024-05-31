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

    func pack() -> Result<Data, MessagePackError> {
        let value = packValue()
        switch value {
        case .value(let value):
            return packWithOption(value: value)
        case .valueWithOption(let value, let option):
            return packWithOption(value: value, option: option)
        case .structure(let values):
            return packStructure(values: values)
        }
    }

    private func packWithOption(value: any MessagePackable) -> Result<Data, MessagePackError> {
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
            return packWithOption(value: value, option: .str_32)
        case is Data:
            return packWithOption(value: value, option: .bin_32)
        case is Array<any MessagePackable>:
            return packWithOption(value: value, option: .array_32)
        case is Bool:
            return packWithOption(value: value, option: self as! Bool ? .true : .false)
        // case is Dictionary<MessagePackable, MessagePackable>:  // ????
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
        case .structure(let values):
            return await packStructure(values: values)
        }
    }

    private func packWithOption(value: any MessagePackable) async -> Result<Data, MessagePackError> {
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
            return await packWithOption(value: value, option: .str_32)
        case is Data:
            return await packWithOption(value: value, option: .bin_32)
        case is Array<any MessagePackable>:
            return await packWithOption(value: value, option: .array_32)
        case is Bool:
            return await packWithOption(value: value, option: self as! Bool ? .true : .false)
        // case is Dictionary<MessagePackable, MessagePackable>: // ????
        //     break
        default:
            return .failure(.unknownType)
        }
    }

    private func packWithOption(
        value: any MessagePackable,
        option: MessagePackType
    ) -> Result<Data, MessagePackError> {
        return .failure(.notImplemented)
    }

    private func packWithOption(
        value: any MessagePackable,
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
