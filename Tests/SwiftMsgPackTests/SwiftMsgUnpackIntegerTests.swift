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
            XCTAssertEqual(unpackedData, [0x7f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackUInt16() {
        let data = Data([MessagePackType.uint_16.rawValue, 0x00, 0x7f])
        let msgData = MessagePackData(data: data)
        let unpacked = msgData.unpack()
        switch unpacked {
        case .success(let unpackedData):
            guard let unpackedData = unpackedData as? [UInt16] else {
                XCTFail("Unpacked data is not [UInt16]")
                return
            }
            XCTAssertEqual(unpackedData, [0x7f])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }
}
