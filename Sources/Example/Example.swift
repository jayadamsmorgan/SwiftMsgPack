import Foundation
import SwiftMsgPack

struct Example: MessagePackable, CustomStringConvertible {
    var name: String = "John Doe"
    var age: Int = 42
    var data: Data = Data([0x01, 0x02, 0x03])
    var array: [Int] = [1, 2, 3]
    var dictionary: [String: Int] = ["one": 1, "two": 2, "three": 3]

    func packValue() -> MessagePackValue {
        return .structure([
            .valueWithOption(name, option: .str_8),
            .value(age),
            .valueWithOption(data, option: .bin_8),
            .value(array),
            .valueWithOption(dictionary, option: .map_16),
        ])
    }

    var description: String {
        "Example(name: \(name), age: \(age), data: \(data), array: \(array), dictionary: \(dictionary))"
    }
}

// Synchonous
print("Sync:")
let example = Example()
let packed = example.pack()
print("Packed: \(packed)")
// First way
do {
    let unpacked: Example = try MessagePackData(data: packed).unpack()
    print("Unpacked: \(unpacked)")
} catch {
    print("Unpacking error: \(error)")
}
// Second way
// let unpacked2: Result<Example, MessagePackError> = MessagePackData(data: packed).unpack()
// switch unpacked2 {
// case .success(let unpacked):
//     print(unpacked)
// case .failure(let error):
//     print(error)
// }

func asyncUnpack() async {
    let example = Example()
    let packed = example.pack()
    print("Packed async: \(packed)")
    // First way
    do {
        let unpacked: Example = try await MessagePackData(data: packed).unpack()
        print("Unpacked async: \(unpacked)")
    } catch {
        print("Unpacking async error: \(error)")
    }
    // Second way
    // let unpacked2: Result<Example, MessagePackError> = await MessagePackData(data: packed).unpack()
    // switch unpacked2 {
    // case .success(let unpacked):
    //     print(unpacked)
    // case .failure(let error):
    //     print(error)
    // }
}

// Asynchonous
if #available(macOS 15.0, *) {
    print("Async:")
    Task {
        await asyncUnpack()
    }
}

sleep(1)
