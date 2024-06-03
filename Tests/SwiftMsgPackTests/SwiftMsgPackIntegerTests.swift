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
    }

}
