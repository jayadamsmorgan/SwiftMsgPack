import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackStringTests: XCTestCase {

    // TODO: Async tests

    func testStringPack() {
        let emptyString = ""
        let packedEmpty = emptyString.pack()
        switch packedEmpty {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue)
            XCTAssertEqual(data.count, 1)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string = "Hello, World!"
        let packed = string.pack()
        switch packed {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue + UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[1...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string2 =
            "Hello, World, this is a very long string! Very long indeed! And it's even longer than the previous one!"
        let packed2 = string2.pack()
        switch packed2 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string2.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_8.rawValue)
            XCTAssertEqual(data[1], UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[2...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string3 = String(
            repeating: """
                Hello, World, this is a very long string! Very long indeed! And it's even longer than the previous one!
                And it has a newline character!
                """,
            count: 100
        )
        let packed3 = string3.pack()
        switch packed3 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string3.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_16.rawValue)
            let bytes = withUnsafeBytes(of: stringBytesToCompare.count, Array.init)
            XCTAssertEqual(data[1], bytes[1])
            XCTAssertEqual(data[2], bytes[0])
            XCTAssertEqual(data[3...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string4 = String(repeating: string3, count: 100)
        let packed4 = string4.pack()
        switch packed4 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string4.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_32.rawValue)
            let bytes = withUnsafeBytes(of: stringBytesToCompare.count, Array.init)
            XCTAssertEqual(data[1], bytes[3])
            XCTAssertEqual(data[2], bytes[2])
            XCTAssertEqual(data[3], bytes[1])
            XCTAssertEqual(data[4], bytes[0])
            XCTAssertEqual(data[5...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testStringPackWithConstraints() {
        let emptyString = ""
        let packedEmpty = emptyString.pack(constraint: .str_8)
        switch packedEmpty {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.str_8.rawValue)
            XCTAssertEqual(data[1], 0)
            XCTAssertEqual(data.count, 2)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string1 = "Hello, World!"
        let packed1 = string1.pack(constraint: .fixstr)
        switch packed1 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string1.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue + UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[1...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let packed2 = string1.pack(constraint: .str_8)
        switch packed2 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string1.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_8.rawValue)
            XCTAssertEqual(data[1], UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[2...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let packed3 = string1.pack(constraint: .str_16)
        switch packed3 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string1.data(using: .utf8)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_16.rawValue)
            let bytes = withUnsafeBytes(of: stringBytesToCompare.count, Array.init)
            XCTAssertEqual(data[1], bytes[1])
            XCTAssertEqual(data[2], bytes[0])
            XCTAssertEqual(data[3...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string2 =
            "Hello, World, this is a very long string! Very long indeed! And it's even longer than the previous one!"
        let packed5 = string2.pack(constraint: .fixstr)
        switch packed5 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = Array(string2.data(using: .utf8)!.map { UInt8($0) }.prefix(upTo: 31))
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue + 31)
            XCTAssertEqual(data[1...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let packed6 = string2.pack(constraint: .int_32)
        XCTAssertEqual(packed6, .failure(.invalidData))
    }

    func testStringPackWithEncoding() {
        let emptyString = ""
        let packedEmpty = emptyString.pack(with: .utf16)
        switch packedEmpty {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue)
            XCTAssertEqual(data.count, 1)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string1 = "Hello, World!"
        let packed1 = string1.pack(with: .utf16)
        switch packed1 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string1.data(using: .utf16)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.fixstr.rawValue + UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[1...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string2 =
            "Hello, World, this is a very long string! Very long indeed! And it's even longer than the previous one!"
        let packed2 = string2.pack(with: .utf16)
        switch packed2 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string2.data(using: .utf16)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_8.rawValue)
            XCTAssertEqual(data[1], UInt8(stringBytesToCompare.count))
            XCTAssertEqual(data[2...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string3 = String(
            repeating: """
                Hello, World, this is a very long string! Very long indeed! And it's even longer than the previous one!
                And it has a newline character!
                """,
            count: 100
        )
        let packed3 = string3.pack(with: .utf16)
        switch packed3 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string3.data(using: .utf16)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_16.rawValue)
            let bytes = withUnsafeBytes(of: stringBytesToCompare.count, Array.init)
            XCTAssertEqual(data[1], bytes[1])
            XCTAssertEqual(data[2], bytes[0])
            XCTAssertEqual(data[3...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let string4 = String(repeating: string3, count: 100)
        let packed4 = string4.pack(with: .utf16)
        switch packed4 {
        case .success(let data):
            let stringBytesToCompare: [UInt8] = string4.data(using: .utf16)!.map { UInt8($0) }
            XCTAssertEqual(data[0], MessagePackType.str_32.rawValue)
            let bytes = withUnsafeBytes(of: stringBytesToCompare.count, Array.init)
            XCTAssertEqual(data[1], bytes[3])
            XCTAssertEqual(data[2], bytes[2])
            XCTAssertEqual(data[3], bytes[1])
            XCTAssertEqual(data[4], bytes[0])
            XCTAssertEqual(data[5...].map { UInt8($0) }, stringBytesToCompare.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }
}
