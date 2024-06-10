import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackFloatTests: XCTestCase {

    func testUnpackFloat32() {
        let float: UInt32 = Float32(252).bitPattern
        let floatBytes = withUnsafeBytes(of: float, Array.init)
        let data = Data([MessagePackType.float_32.rawValue] + floatBytes)
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Float32] else {
                XCTFail("Unpacked data is not [Float32]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Float32(252)])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackFloat64() {
        let float: UInt64 = Float64(252).bitPattern
        let floatBytes = withUnsafeBytes(of: float, Array.init)
        let data = Data([MessagePackType.float_64.rawValue] + floatBytes)
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Float64] else {
                XCTFail("Unpacked data is not [Float64]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Float64(252)])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

}
