import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackBoolTests: XCTestCase {

    func testBool() {
        var bool = false
        let result = bool.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.false.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

        bool = true
        let result2 = bool.pack()
        switch result2 {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.true.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

    }

}
