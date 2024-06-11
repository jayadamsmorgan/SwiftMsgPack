import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackArrayTests: XCTestCase {

    func testUnpackFixArray() {
        let data = Data([
            MessagePackType.fixarray.rawValue | 0x03,
            MessagePackType.uint_8.rawValue, 127,
            MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual((arr[0] as! [Any?]).count, 3)
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

    func testUnpackArray16() {
        let data = Data([
            MessagePackType.array_16.rawValue, 0x00, 0x03,
            MessagePackType.uint_8.rawValue, 127,
            MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual((arr[0] as! [Any?]).count, 3)
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

    func testUnpackArray32() {
        let data = Data([
            MessagePackType.array_32.rawValue, 0x00, 0x00, 0x00, 0x03,
            MessagePackType.uint_8.rawValue, 127,
            MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual((arr[0] as! [Any?]).count, 3)
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

}
