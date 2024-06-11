import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackDictionaryTests: XCTestCase {

    func testUnpackFixMap() {
        let data = Data([
            MessagePackType.fixmap.rawValue | 3,
            MessagePackType.uint_8.rawValue, 127, MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129, MessagePackType.uint_8.rawValue, 130,
            MessagePackType.uint_8.rawValue, 131, MessagePackType.uint_8.rawValue, 132,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let dict):
            guard let dict = dict as? [[UInt8: UInt8]] else {
                XCTFail("Unpacked data is not [UInt8: UInt8]: \(dict)")
                return
            }
            XCTAssertEqual(dict[0], [127: 128, 129: 130, 131: 132])
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

    func testUnpackMap16() {
        let data = Data([
            MessagePackType.map_16.rawValue, 0, 3,
            MessagePackType.uint_8.rawValue, 127, MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129, MessagePackType.uint_8.rawValue, 130,
            MessagePackType.uint_8.rawValue, 131, MessagePackType.uint_8.rawValue, 132,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let dict):
            guard let dict = dict as? [[UInt8: UInt8]] else {
                XCTFail("Unpacked data is not [UInt8: UInt8]: \(dict)")
                return
            }
            XCTAssertEqual(dict[0], [127: 128, 129: 130, 131: 132])
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

    func testUnpackMap32() {
        let data = Data([
            MessagePackType.map_32.rawValue, 0, 0, 0, 3,
            MessagePackType.uint_8.rawValue, 127, MessagePackType.uint_8.rawValue, 128,
            MessagePackType.uint_8.rawValue, 129, MessagePackType.uint_8.rawValue, 130,
            MessagePackType.uint_8.rawValue, 131, MessagePackType.uint_8.rawValue, 132,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let dict):
            guard let dict = dict as? [[UInt8: UInt8]] else {
                XCTFail("Unpacked data is not [UInt8: UInt8]: \(dict)")
                return
            }
            XCTAssertEqual(dict[0], [127: 128, 129: 130, 131: 132])
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }
}
