import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackNilTests: XCTestCase {

    func testNilPack() {
        let opt: Int? = nil
        let result = opt.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.nil.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

}
