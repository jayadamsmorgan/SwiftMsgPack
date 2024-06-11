import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackBinTests: XCTestCase {

    func testPackBin8() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        let packResult = data.pack()
        switch packResult {
        case .success(let packed):
            XCTAssertEqual(
                packed.map { UInt8($0) },
                [MessagePackType.bin_8.rawValue, 0x05, 0x00, 0x01, 0x02, 0x03, 0x04]
            )
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

    func testPackBin16() {
        let data = Data(Array<UInt8>(repeating: 0x17, count: 256))
        let packResult = data.pack()
        switch packResult {
        case .success(let packed):
            XCTAssertEqual(
                packed.map { UInt8($0) },
                [MessagePackType.bin_16.rawValue, 0x01, 0x00] + Array<UInt8>(repeating: 0x17, count: 256)
            )
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

    func testPackBin32() {
        let data = Data(Array<UInt8>(repeating: 0x17, count: 65536))
        let packResult = data.pack()
        switch packResult {
        case .success(let packed):
            XCTAssertEqual(
                packed.map { UInt8($0) },
                [MessagePackType.bin_32.rawValue, 0x00, 0x01, 0x00, 0x00] + Array<UInt8>(repeating: 0x17, count: 65536)
            )
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

    func testPackUnpackBin() {
        let data = Data([0x00, 0x01, 0x02, 0x03, 0x04])
        let packResult = data.pack()
        switch packResult {
        case .success(let packed):
            let unpackResult = MessagePackData(data: packed).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertEqual(unpacked[0] as! Data, data)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

}
