import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackIntegerTests: XCTestCase {

    func testUnpackPositiveFixInt() {
        let data = Data([0x7e])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt8] else {
                XCTFail("Unpacked data is not [UInt8]")
                return
            }
            let expected: UInt8 = 0x7e - MessagePackType.positive_fixint.rawValue
            XCTAssertEqual(unpackedData, [expected])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackNegativeFixInt() {
        let data = Data([0xff])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [Int8] else {
                XCTFail("Unpacked data is not [Int8]")
                return
            }
            let expected: Int8 = Int8(bitPattern: MessagePackType.negative_fixint.rawValue) - Int8(bitPattern: 0xff)
            XCTAssertEqual(unpackedData, [expected])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackUInt8() {
        let data = Data([MessagePackType.uint_8.rawValue, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt8] else {
                XCTFail("Unpacked data is not [UInt8]")
                return
            }
            XCTAssertEqual(unpackedData, [UInt8(0x7f)])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackInt8() {
        let data = Data([MessagePackType.int_8.rawValue, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [Int8] else {
                XCTFail("Unpacked data is not [Int8]")
                return
            }
            XCTAssertEqual(unpackedData, [Int8(0x7f)])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackUInt16() {
        let data = Data([MessagePackType.uint_16.rawValue, 0x01, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt16] else {
                XCTFail("Unpacked data is not [UInt16]")
                return
            }
            XCTAssertEqual(unpackedData, [0x017f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackInt16() {
        let data = Data([MessagePackType.int_16.rawValue, 0x01, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [Int16] else {
                XCTFail("Unpacked data is not [Int16]")
                return
            }
            XCTAssertEqual(unpackedData, [0x017f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackUInt32() {
        let data = Data([MessagePackType.uint_32.rawValue, 0x01, 0x00, 0x00, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt32] else {
                XCTFail("Unpacked data is not [UInt32]")
                return
            }
            XCTAssertEqual(unpackedData, [0x0100007f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackInt32() {
        let data = Data([MessagePackType.int_32.rawValue, 0x01, 0x00, 0x00, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [Int32] else {
                XCTFail("Unpacked data is not [Int32]")
                return
            }
            XCTAssertEqual(unpackedData, [0x0100007f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackUInt64() {
        let data = Data([MessagePackType.uint_64.rawValue, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt64] else {
                XCTFail("Unpacked data is not [UInt64]")
                return
            }
            XCTAssertEqual(unpackedData, [0x010000000000007f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackInt64() {
        let data = Data([MessagePackType.int_64.rawValue, 0x01, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [Int64] else {
                XCTFail("Unpacked data is not [Int64]")
                return
            }
            XCTAssertEqual(unpackedData, [0x010000000000007f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackIndexOutOfBounds() {
        let data = Data([MessagePackType.uint_8.rawValue])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success:
            XCTFail("Unpacking should fail")
        case .failure(let error):
            XCTAssertEqual(error, MessagePackError.unpackIndexOutOfBounds)
        }
    }
}
