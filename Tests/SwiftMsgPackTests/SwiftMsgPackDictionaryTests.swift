import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackDictionaryTests: XCTestCase {

    func testPackFixMap() {
        let dict: [String: Int] = ["a": 1, "b": 2]
        let result = dict.pack()
        switch result {
        case .success(let data):
            XCTAssertTrue(
                data.map { UInt8($0) } == [
                    MessagePackType.fixmap.rawValue | 2,
                    MessagePackType.fixstr.rawValue | 1, 0x61,
                    MessagePackType.int_64.rawValue, 0, 0, 0, 0, 0, 0, 0, 1,
                    MessagePackType.fixstr.rawValue | 1, 0x62,
                    MessagePackType.int_64.rawValue, 0, 0, 0, 0, 0, 0, 0, 2,
                ]
                    || data.map { UInt8($0) } == [
                        MessagePackType.fixmap.rawValue | 2,
                        MessagePackType.fixstr.rawValue | 1, 0x62,
                        MessagePackType.int_64.rawValue, 0, 0, 0, 0, 0, 0, 0, 2,
                        MessagePackType.fixstr.rawValue | 1, 0x61,
                        MessagePackType.int_64.rawValue, 0, 0, 0, 0, 0, 0, 0, 1,
                    ]
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackMap16() {
        var dict: [String: Int] = [:]
        for i in 0..<17 {
            dict["\(i)"] = i
        }
        let result = dict.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.map_16.rawValue)
            XCTAssertEqual(data[1], 0)
            XCTAssertEqual(data[2], 17)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackMap32() {
        var dict: [String: Int] = [:]
        for i in 0..<Int(UInt16.max) + 1 {
            dict["\(i)"] = i
        }
        let result = dict.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.map_32.rawValue)
            XCTAssertEqual(data[1], 0)
            XCTAssertEqual(data[2], 1)
            XCTAssertEqual(data[3], 0)
            XCTAssertEqual(data[4], 0)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackMap() {
        let dict: [String: Int64] = ["a": 1, "b": 2]
        let result = dict.pack()
        switch result {
        case .success(let data):
            let msgData = MessagePackData(data: data)
            let unpacked = msgData.unpack()
            switch unpacked {
            case .success(let unpackedDict):
                XCTAssertEqual(unpackedDict.count, 1)
                XCTAssertEqual(unpackedDict[0] as! [String: Int64], dict)
            case .failure(let error):
                XCTFail("Unpacking error: \(error)")
            }
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

}
