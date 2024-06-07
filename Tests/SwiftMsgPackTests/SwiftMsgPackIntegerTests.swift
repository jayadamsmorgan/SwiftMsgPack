import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackIntegerTests: XCTestCase {

    // TODO: Async tests

    func testIntPack() {
        let int1: Int64 = 0
        let packed1 = int1.pack()
        switch packed1 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.int_64.rawValue)
            for byte in data[1...] {
                XCTAssertEqual(byte, 0)
            }
            XCTAssertEqual(data.count, 9)  // 8 byte (Int64) + 1st byte
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let int2: Int = 123_456_789
        let packed2 = int2.pack()
        switch packed2 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.int_64.rawValue)
            let bytes = withUnsafeBytes(of: int2.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
            XCTAssertEqual(data.count, 9)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let int3: UInt8 = 0x7d
        let packed3 = int3.packWithFixInt()
        switch packed3 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.positive_fixint.rawValue + int3)
            XCTAssertEqual(data.count, 1)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
        let int31: UInt8 = MessagePackType.negative_fixint_max - MessagePackType.negative_fixint.rawValue - 1
        let packed31 = int31.packWithFixInt(negative: true)
        switch packed31 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.negative_fixint.rawValue + int31)
            XCTAssertEqual(data.count, 1)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let int4: UInt8 = 253
        let packed4 = int4.packWithFixInt()
        switch packed4 {
        case .success(_):
            XCTFail("Packed while error was expected.")
        case .failure(let error):
            XCTAssertEqual(error, .constraintOverflow)
        }

        let int5: UInt8 = 123
        let packed5 = int5.pack()
        switch packed5 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.uint_8.rawValue)
            let bytes = withUnsafeBytes(of: int5.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        let int6: UInt64 = 123_456_789_101
        let packed6 = int6.pack()
        switch packed6 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.uint_64.rawValue)
            let bytes = withUnsafeBytes(of: int6.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

}
