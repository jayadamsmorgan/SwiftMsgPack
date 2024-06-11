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

struct Example: MessagePackable {

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
}

@main
public struct ExampleApp {

    static func main() {
        let example = Example()
        do {
            let packed: Data = try example.pack().get()
            print("Packed:\n\(packed.withUnsafeBytes(Array.init))")
            let unpacked: [Any?] = try MessagePackData(data: packed).unpack().get()
            print("Unpacked:\n\(unpacked)")
        } catch {
            print("Unpacking error: \(error)")
        }
    }
}
```

[msgpack]: https://msgpack.org
[example]: https://github.com/jayadamsmorgan/SwiftMsgPack/blob/main/Sources/Example/Example.swift
