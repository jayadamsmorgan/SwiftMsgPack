import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackBoolTests: XCTestCase {

    func testUnpackTrue() {
        let data = Data([MessagePackType.true.rawValue])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Bool] else {
                XCTFail("Unpacked data is not [Bool]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [true])
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

    func testUnpackFalse() {
        let data = Data([MessagePackType.false.rawValue])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Bool] else {
                XCTFail("Unpacked data is not [Bool]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [false])
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

}
