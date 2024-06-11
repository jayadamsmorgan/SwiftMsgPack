import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackBoolTests: XCTestCase {

    func testPackTrue() {
        let bool = true
        let result2 = bool.pack()
        switch result2 {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.true.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

    }

    func testPackFalse() {
        let bool = false
        let result = bool.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.false.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackBool() {
        let bool = true
        let result = bool.pack()
        switch result {
        case .success(let data):
            let unpackResult = MessagePackData(data: data).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertEqual(unpacked[0] as! Bool, bool)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

}
