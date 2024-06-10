import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackStringTests: XCTestCase {

    func testUnpackFixStr() {
        let str = "Hello, World!"
        let strData = str.data(using: .utf8)!
        let data = Data([MessagePackType.fixstr.rawValue + 13]) + strData
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [String] else {
                XCTFail("Unpacked data is not [String]: \(arr)")
                return
            }
            XCTAssertEqual(arr, ["Hello, World!"])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackStr8() {
        let str = "Hello, World!"
        let strData = str.data(using: .utf8)!
        let data = Data([MessagePackType.str_8.rawValue, UInt8(13)]) + strData
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [String] else {
                XCTFail("Unpacked data is not [String]: \(arr)")
                return
            }
            XCTAssertEqual(arr, ["Hello, World!"])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackStr16() {
        let str = "Hello, World!"
        let strData = str.data(using: .utf8)!
        let data = Data([MessagePackType.str_16.rawValue, UInt8(0), UInt8(13)]) + strData
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [String] else {
                XCTFail("Unpacked data is not [String]: \(arr)")
                return
            }
            XCTAssertEqual(arr, ["Hello, World!"])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackStr32() {
        let str = "Hello, World!"
        let strData = str.data(using: .utf8)!
        let data = Data([MessagePackType.str_32.rawValue, UInt8(0), UInt8(0), UInt8(0), UInt8(13)]) + strData
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [String] else {
                XCTFail("Unpacked data is not [String]: \(arr)")
                return
            }
            XCTAssertEqual(arr, ["Hello, World!"])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

}
