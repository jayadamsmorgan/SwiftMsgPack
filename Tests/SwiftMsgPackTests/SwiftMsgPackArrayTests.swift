import XCTest

@testable import SwiftMsgPack

final class SwiftMsgPackArrayTests: XCTestCase {

    func testPackFixArray() {
        let optionalValue: Int? = nil
        let array: [MessagePackable] = [Int(5), UInt16(22), optionalValue, "Hello, World!", true, Float64(44.5533)]
        let packResult = array.pack()
        switch packResult {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.fixarray.rawValue | 6)
            XCTAssertEqual(data[1], MessagePackType.int_64.rawValue)
            XCTAssertEqual(data[2], 0)
            XCTAssertEqual(data[3], 0)
            XCTAssertEqual(data[4], 0)
            XCTAssertEqual(data[5], 0)
            XCTAssertEqual(data[6], 0)
            XCTAssertEqual(data[7], 0)
            XCTAssertEqual(data[8], 0)
            XCTAssertEqual(data[9], 5)
            XCTAssertEqual(data[10], MessagePackType.uint_16.rawValue)
            XCTAssertEqual(data[11], 0)
            XCTAssertEqual(data[12], 22)
            XCTAssertEqual(data[13], MessagePackType.nil.rawValue)
            XCTAssertEqual(data[14], MessagePackType.fixstr.rawValue | 13)
            XCTAssertEqual(data[15...27], "Hello, World!".data(using: .utf8))
            XCTAssertEqual(data[28], MessagePackType.true.rawValue)
            XCTAssertEqual(data[29], MessagePackType.float_64.rawValue)
            let bytes = withUnsafeBytes(of: Float64(44.5533).bitPattern, Array.init)
            XCTAssertEqual(data[30...].map { UInt8($0) }, bytes.map { UInt8($0) })
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackArray16() {
        let array: [MessagePackable] = .init(repeating: UInt8(5), count: 255)
        let packResult = array.pack()
        switch packResult {
        case .success(let data):
            XCTAssertEqual(data.count, 513)
            XCTAssertEqual(data[0], MessagePackType.array_16.rawValue)
            XCTAssertEqual(data[1], 0)
            XCTAssertEqual(data[2], 255)
            var i = 3
            while i < data.count {
                XCTAssertEqual(data[i], MessagePackType.uint_8.rawValue)
                XCTAssertEqual(data[i + 1], 5)
                i += 2
            }
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackArray32() {
        let array: [MessagePackable] = .init(repeating: UInt8(5), count: Int(UInt16.max) + 1)
        let packResult = array.pack()
        switch packResult {
        case .success(let data):
            XCTAssertEqual(data.count, array.count * 2 + 5)
            XCTAssertEqual(data[0], MessagePackType.array_32.rawValue)
            XCTAssertEqual(data[1], 0)
            XCTAssertEqual(data[2], 1)
            XCTAssertEqual(data[3], 0)
            XCTAssertEqual(data[4], 0)
            var i = 5
            while i < data.count {
                XCTAssertEqual(data[i], MessagePackType.uint_8.rawValue)
                XCTAssertEqual(data[i + 1], 5)
                i += 2
            }
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackEmptyArray() {
        let array: [MessagePackable] = []
        let packResult = array.pack()
        switch packResult {
        case .success(let data):
            XCTAssertEqual(data[0], MessagePackType.fixarray.rawValue)
            XCTAssertEqual(data.count, 1)
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }
    }

    func testPackUnpackArray() {
        let optionalValue: Int? = nil
        let array: [MessagePackable] = [Int(5), UInt16(22), optionalValue, "Hello, World!", true, Float64(44.5533)]
        let packResult = array.pack()
        switch packResult {
        case .success(let data):
            let msgData = MessagePackData(data: data)
            let unpackResult = msgData.unpack()
            switch unpackResult {
            case .success(let resultArray):
                XCTAssertEqual(resultArray.count, 1)
                guard let resultArray = resultArray[0] as? [Any?] else {
                    XCTFail("Unpacked array is not [MessagePackable]: \(resultArray)")
                    return
                }
                XCTAssertEqual(resultArray.count, array.count)
                XCTAssertEqual(resultArray[0] as! Int64, 5)
                XCTAssertEqual(resultArray[1] as! UInt16, 22)
                XCTAssertEqual(resultArray[2] as! Int?, nil)
                XCTAssertEqual(resultArray[3] as! String, "Hello, World!")
                XCTAssertEqual(resultArray[4] as! Bool, true)
                XCTAssertEqual(resultArray[5] as! Float64, 44.5533)
            case .failure(let error):
                XCTFail("Unpacking error: \(error)")
            }
        case .failure(let error):
            XCTFail("Packing error: \(error)")
        }

    }

}
