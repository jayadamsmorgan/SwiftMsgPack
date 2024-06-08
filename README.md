<div align="center">

# SwiftMsgPack 

[WIP] Really simple Swift library for [MessagePack][msgpack]

</div>


## Usage

##### Package.swift

```swift
// swift-tools-version: 5.8

import PackageDescription

let package = Package(
    name: "MsgPackTest",
    dependencies: [
        .package(url: "https://github.com/jayadamsmorgan/SwiftMsgPack", branch: "main")
    ],
    targets: [
        .executableTarget(
            name: "SwiftMsgPackExample",
            dependencies: ["SwiftMsgPack"]
        )
    ]
)
```

## Implementation

Check [Example.swift][example] for `async` implementations too!

```swift
import Foundation
import SwiftMsgPack

struct Example: MessagePackable, CustomStringConvertible {

    var name: String = "John Doe"
    var age: Int = 42
    var data: Data = Data([0x01, 0x02, 0x03])
    var array: [Int] = [1, 2, 3]

    func packValue() -> MessagePackValue {
        return .structure([
            .string(name, encoding: .utf8),
            .value(age),
            .valueWithOption(data, option: .bin_8),
            .value(array),
        ])
    }

    var description: String {
        "Example(name: \(name), age: \(age), data: \(data), array: \(array)"
    }
}

let int: Int = 123
// Same for Int (all bits), UInt (all bits), Float(all bits), String (with encoding options), Arrays, etc
// Dictionary is not yet supported
let packedResult: Result<Data, MessagePackError> = int.pack()
switch packed {
case .success(let data):
    print(data)
case .failure(let error):
    print(error)
}

do {
    let packed: Data = try example.pack().get()
    print("Packed: \(packed.withUnsafeBytes(Array.init))")
    let unpacked: [Any] = try MessagePackData(data: packed).unpack().get()
    print("Unpacked: \(unpacked)")
} catch {
    print("Unpacking error: \(error)")
}
```

[msgpack]: https://msgpack.org
[example]: https://github.com/jayadamsmorgan/SwiftMsgPack/blob/main/Sources/Example/Example.swift
