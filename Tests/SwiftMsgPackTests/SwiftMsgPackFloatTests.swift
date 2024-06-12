import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackFloatTests: XCTestCase {

    func testPackFloat32() {
        let float: Float32 = 3.14
        let result = float.pack()
        switch result {
        case .success(let data):
            let bytes: [UInt8] = withUnsafeBytes(of: float, Array.init)
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.float_32.rawValue] + bytes
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackFloat64() {
        let double: Float64 = 3.14
        let result = double.pack()
        switch result {
        case .success(let data):
            let bytes: [UInt8] = withUnsafeBytes(of: double, Array.init)
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.float_64.rawValue] + bytes
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackFloat32() {
        let float: Float32 = 3.14
        let result = float.pack()
        switch result {
        case .success(let data):
            let unpackResult = MessagePackData(data: data).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertEqual(unpacked[0] as! Float32, float)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

    func testPackUnpackFloat64() {
        let double: Float64 = 3.14
        let result = double.pack()
        switch result {
        case .success(let data):
            let unpackResult = MessagePackData(data: data).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertEqual(unpacked[0] as! Float64, double)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

}
