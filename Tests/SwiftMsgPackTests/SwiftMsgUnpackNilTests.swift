import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackNilTests: XCTestCase {

    func testUnpackNil() {
        let data = Data([MessagePackType.nil.rawValue])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            XCTAssertEqual(arr.count, 1)
            guard let arr = arr[0] as? Optional<Bool> else {  // Could be any equatable type
                XCTFail("Unpacked data is not [Optional<Any>]: \(arr)")
                return
            }
            XCTAssertEqual(arr, nil)
        case .failure(let error):
            XCTFail("Failed to unpack: \(error)")
        }
    }

}
