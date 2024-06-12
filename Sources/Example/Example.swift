import Foundation
import SwiftMsgPack

struct Example: MessagePackable {

    var name: String = "John Doe"
    var age: Int = 42
    var data: Data = Data([0x01, 0x02, 0x03])
    var array: [Int] = [1, 2, 3]
    var map: [String: Int] = ["a": 1, "b": 2, "c": 3]
    var timestamp: Date = Date()

    var optional: Int? = nil

    func packValue() -> MessagePackValue {
        return .structure([
            .string(name, encoding: .utf8),
            .value(age),
            .valueWithOption(data, option: .bin_8),
            .value(array),
            .value(map),
            .value(timestamp),
            .value(optional),
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
}

@main
public struct ExampleApp {

    static func main() {
        // Synchronous
        syncPackUnpack()

        // Asynchonous
        if #available(macOS 10.15.0, iOS 15.0, *) {
            Task {
                await asyncPackUnpack()
            }
        }

        sleep(1)
    }

    static func syncPackUnpack() {
        print()
        let example = Example()
        do {
            let packed: Data = try example.pack().get()
            print("Packed:\n\(packed.withUnsafeBytes(Array.init))")
            let unpacked: [Any?] = try MessagePackData(data: packed).unpack().get()
            print("Unpacked:\n\(unpacked)")
            // Int and Int64 are packed as Int64 but unpacked as Int64 only, same goes for UInt and UInt64:
            let _ = unpacked[1] as! Int64
        } catch {
            print("Unpacking error: \(error)")
        }
        print()
    }

    @available(macOS 10.15.0, iOS 15.0, *)
    static func asyncPackUnpack() async {
        print("Async:")
        let example = Example()
        do {
            let packed = try await example.pack().get()
            print("Packed async:\n\(packed.withUnsafeBytes(Array.init))")
            let unpacked: [Any?] = try await MessagePackData(data: packed).unpack().get()
            print("Unpacked async:\n\(unpacked)")
        } catch {
            print("Unpacking async error: \(error)")
        }
        print()
    }
}
