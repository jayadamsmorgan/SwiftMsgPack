import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackNilTests: XCTestCase {

    func testPackNil() {
        let opt: Int? = nil
        let result = opt.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.nil.rawValue])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackNil() {
        let opt: Int? = nil
        let result = opt.pack()
        switch result {
        case .success(let data):
            let unpackResult = MessagePackData(data: data).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertNil(unpacked[0] as? Int)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

}
