import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackIntegerTests: XCTestCase {

    // TODO: Async tests

    func testPackInt64() {
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
    }

    func testPackInt() {
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
    }

    func testPackUInt8() {
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
    }

    func testPackUInt64() {
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

    func testPackInt8() {
        let int8: Int8 = 123
        let packed8 = int8.pack()
        switch packed8 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.int_8.rawValue)
            let bytes = withUnsafeBytes(of: int8.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUInt16() {
        let int7: UInt16 = 12345
        let packed7 = int7.pack()
        switch packed7 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.uint_16.rawValue)
            let bytes = withUnsafeBytes(of: int7.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackInt16() {
        let int9: Int16 = 12345
        let packed9 = int9.pack()
        switch packed9 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.int_16.rawValue)
            let bytes = withUnsafeBytes(of: int9.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUInt32() {
        let int10: UInt32 = 123_456
        let packed10 = int10.pack()
        switch packed10 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.uint_32.rawValue)
            let bytes = withUnsafeBytes(of: int10.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackInt32() {
        let int11: Int32 = 123_456
        let packed11 = int11.pack()
        switch packed11 {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.int_32.rawValue)
            let bytes = withUnsafeBytes(of: int11.bigEndian, Array.init)
            XCTAssertEqual(data[1...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackInt() {
        let i = Int(54)
        let packResult = i.pack()
        switch packResult {
        case .success(let data):
            let msgData = MessagePackData(data: data)
            let unpackResult = msgData.unpack()
            switch unpackResult {
            case .success(let resultArray):
                XCTAssertEqual(resultArray[0] as! Int64, 54)
            case .failure(let error):
                XCTFail("Unpacking error: \(error)")
            }
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

    }

}
