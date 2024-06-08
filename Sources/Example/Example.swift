import Foundation
import SwiftMsgPack

struct Example: MessagePackable, CustomStringConvertible {

    var name: String = "John Doe"
    var age: Int = 42
    var data: Data = Data([0x01, 0x02, 0x03])
    var array: [Int] = [1, 2, 3]
    var map: [String: Int] = ["a": 1, "b": 2, "c": 3]
    var timestamp: Date = Date()

    func packValue() -> MessagePackValue {
        return .structure([
            .string(name, encoding: .utf8),
            .value(age),
            .valueWithOption(data, option: .bin_8),
            .value(array),
            .value(map),
            .value(timestamp),
        ])
    }

    // func packValue() -> MessagePackValue {
    //     return .structureAsExt(
    //         id: 24,
    //         [
    //             .string(name, encoding: .utf8),
    //             .value(age),
    //             .valueWithOption(data, option: .bin_8),
    //             .value(array),
    //             .value(map),
    //             .date(timestamp, format: .timestamp_64),
    //         ],
    //         constraint: .ext_32  // Optional
    //     )
    // }

    var description: String {
        "Example(name: \(name), age: \(age), data: \(data), array: \(array), map: \(map), timestamp: \(timestamp))"
    }
}

func syncPackUnpack() {
    print("Sync:")
    let example = Example()
    do {
        let packed: Data = try example.pack().get()
        print("Packed: \(packed.withUnsafeBytes(Array.init))")
        let unpacked: [Any?] = try MessagePackData(data: packed).unpack().get()
        print("Unpacked: \(unpacked)")
    } catch {
        print("Unpacking error: \(error)")
    }
}

@available(macOS 10.15.0, iOS 15.0, *)
func asyncPackUnpack() async {
    print("Async:")
    let example = Example()
    do {
        let packed = try await example.pack().get()
        print("Packed async: \(packed.withUnsafeBytes(Array.init))")
        let unpacked: [Any?] = try await MessagePackData(data: packed).unpack().get()
        print("Unpacked async: \(unpacked)")
    } catch {
        print("Unpacking async error: \(error)")
    }
}

// Synchronous
syncPackUnpack()

// Asynchonous
if #available(macOS 10.15.0, iOS 15.0, *) {
    Task {
        await asyncPackUnpack()
    }
}

sleep(1)
