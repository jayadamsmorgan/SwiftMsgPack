import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackBinTests: XCTestCase {

    func testUnpackBin8() {
        let data = Data([MessagePackType.bin_8.rawValue, 6, 123, 11, 122, 232, 23, 11])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Data] else {
                XCTFail("Unpacked data is not [Data]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Data([123, 11, 122, 232, 23, 11])])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackBin16() {
        let data = Data([MessagePackType.bin_16.rawValue, 0, 6, 123, 11, 122, 232, 23, 11])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Data] else {
                XCTFail("Unpacked data is not [Data]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Data([123, 11, 122, 232, 23, 11])])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackBin32() {
        let data = Data([MessagePackType.bin_32.rawValue, 0, 0, 0, 6, 123, 11, 122, 232, 23, 11])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Data] else {
                XCTFail("Unpacked data is not [Data]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Data([123, 11, 122, 232, 23, 11])])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

}
