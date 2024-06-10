import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackArrayTests: XCTestCase {

    func testUnpackFixArray() {
        // let data = Data([
        //     MessagePackType.fixarray.rawValue | 0x03,
        //     MessagePackType.uint_8.rawValue, 0x7f,
        //     MessagePackType.uint_8.rawValue, 0x7f,
        //     MessagePackType.uint_8.rawValue, 0x7f,
        // ])
        // let msgData = MessagePackData(data: data)
        // let result = msgData.unpack()
        // switch result {
        // case .success(let arr):
        //     guard let arr = arr as? [[UInt8]] else {
        //         XCTFail("Unpacked data is not [[UInt8]]: \(arr)")
        //         return
        //     }
        // // XCTAssertEqual(arr.count, 1)
        // // XCTAssertEqual(arr[0].count, 3)
        // case .failure(let error):
        //     XCTFail("Failed to unpack: \(error)")
        // }
    }

}
