import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackExtTests: XCTestCase {

    func testPackFixExt1() {
        let ext = Ext(type: 1, data: Data([0x02]))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.fixext_1.rawValue, ext.utype, 0x02])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackFixExt2() {
        let ext = Ext(type: 1, data: Data([0x02, 0x03]))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(data.map { UInt8($0) }, [MessagePackType.fixext_2.rawValue, ext.utype, 0x02, 0x03])
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackFixExt4() {
        let ext = Ext(type: 1, data: Data([0x02, 0x03, 0x04, 0x05]))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.fixext_4.rawValue, ext.utype, 0x02, 0x03, 0x04, 0x05]
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackFixExt8() {
        let ext = Ext(type: 1, data: Data([0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.fixext_8.rawValue, ext.utype, 0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09]
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackFixExt16() {
        let ext = Ext(
            type: 1,
            data: Data([0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09, 0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11])
        )
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [
                    MessagePackType.fixext_16.rawValue,
                    ext.utype,
                    0x02, 0x03, 0x04, 0x05, 0x06, 0x07, 0x08, 0x09,
                    0x0A, 0x0B, 0x0C, 0x0D, 0x0E, 0x0F, 0x10, 0x11,
                ]
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackExt8() {
        let ext = Ext(type: 1, data: Data(Array<UInt8>(repeating: 0x18, count: 17)))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.ext_8.rawValue, 17, ext.utype] + Array<UInt8>(repeating: 0x18, count: 17)
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackExt16() {
        let ext = Ext(type: 1, data: Data(Array<UInt8>(repeating: 0x18, count: 256)))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.ext_16.rawValue, 1, 0, ext.utype] + Array<UInt8>(repeating: 0x18, count: 256)
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackExt32() {
        let ext = Ext(type: 1, data: Data(Array<UInt8>(repeating: 0x18, count: 65536)))
        let result = ext.pack()
        switch result {
        case .success(let data):
            XCTAssertEqual(
                data.map { UInt8($0) },
                [MessagePackType.ext_32.rawValue, 0, 1, 0, 0, ext.utype] + Array<UInt8>(repeating: 0x18, count: 65536)
            )
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackExt() {
        let ext = Ext(type: 1, data: Data([0x02, 0x03, 0x04, 0x05]))
        let result = ext.pack()
        switch result {
        case .success(let packed):
            let unpackResult = MessagePackData(data: packed).unpack()
            switch unpackResult {
            case .success(let unpacked):
                XCTAssertEqual(unpacked[0] as! Ext, ext)
            case .failure(let error):
                XCTFail("Error: \(error)")
            }
        case .failure(let error):
            XCTFail("Error: \(error)")
        }
    }

}
