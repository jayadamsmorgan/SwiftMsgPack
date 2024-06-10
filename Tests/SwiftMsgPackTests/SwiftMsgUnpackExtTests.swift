import XCTest

@testable import SwiftMsgPack

final class SwiftMsgUnpackExtTests: XCTestCase {

    func testUnpackFixExt1() {
        let data = Data([MessagePackType.fixext_1.rawValue, 12, 127])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackFixExt2() {
        let data = Data([MessagePackType.fixext_2.rawValue, 12, 127, 255])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackFixExt4() {
        let data = Data([MessagePackType.fixext_4.rawValue, 12, 127, 255, 126, 124])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255, 126, 124]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackFixExt8() {
        let data = Data([MessagePackType.fixext_8.rawValue, 12, 127, 255, 126, 124, 243, 177, 43, 23])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255, 126, 124, 243, 177, 43, 23]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackFixExt16() {
        let data = Data([
            MessagePackType.fixext_16.rawValue,
            12, 127, 255, 126, 124, 243, 177, 43, 23, 22, 21, 20, 19, 18, 17, 16, 15,
        ])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(
                arr,
                [
                    Ext(
                        type: Int8(12 + Int8.min),
                        data: Data([127, 255, 126, 124, 243, 177, 43, 23, 22, 21, 20, 19, 18, 17, 16, 15])
                    )
                ]
            )
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackExt8() {
        let data = Data([MessagePackType.ext_8.rawValue, 8, 12, 127, 255, 126, 124, 243, 177, 43, 23])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255, 126, 124, 243, 177, 43, 23]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackExt16() {
        let data = Data([MessagePackType.ext_16.rawValue, 0, 8, 12, 127, 255, 126, 124, 243, 177, 43, 23])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255, 126, 124, 243, 177, 43, 23]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackExt32() {
        let data = Data([MessagePackType.ext_32.rawValue, 0, 0, 0, 8, 12, 127, 255, 126, 124, 243, 177, 43, 23])
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Ext] else {
                XCTFail("Unpacking data is not [Ext]: \(arr)")
                return
            }
            XCTAssertEqual(arr, [Ext(type: Int8(12 + Int8.min), data: Data([127, 255, 126, 124, 243, 177, 43, 23]))])
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackDate32() {
        let date = Date().timeIntervalSince1970
        let dateInterval = UInt32(date).bigEndian
        let dateBytes: [UInt8] = withUnsafeBytes(of: dateInterval, Array.init)
        let data = Data([MessagePackType.fixext_4.rawValue, UInt8(-1 - Int8.min)] + dateBytes)
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Date] else {
                XCTFail("Unpacking data is not [Date]: \(arr)")
                return
            }
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual(Int(arr[0].timeIntervalSince1970), Int(date))
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackDate64() {
        let date = Date().timeIntervalSince1970
        let seconds = UInt64(date)
        let nanos = UInt64((date - Double(seconds)) * 1_000_000_000)
        let dateInterval = (nanos << 34) | seconds
        let dateBytes: [UInt8] = withUnsafeBytes(of: dateInterval, Array.init)
        let data = Data([MessagePackType.fixext_8.rawValue, UInt8(-1 - Int8.min)] + dateBytes)
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Date] else {
                XCTFail("Unpacking data is not [Date]: \(arr)")
                return
            }
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual(Double(arr[0].timeIntervalSince1970), Double(date))
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }

    func testUnpackDate96() {
        let date = Date().timeIntervalSince1970
        let seconds = UInt64(date)
        let nanoDouble = (date - Double(seconds)) * 1_000_000_000
        let nanos = UInt32(nanoDouble)
        let dateBytes: [UInt8] =
            withUnsafeBytes(of: nanos.bigEndian, Array.init) + withUnsafeBytes(of: seconds.bigEndian, Array.init)
        let data = Data([MessagePackType.ext_8.rawValue, 12, UInt8(-1 - Int8.min)] + dateBytes)
        let msgData = MessagePackData(data: data)
        let result = msgData.unpack()
        switch result {
        case .success(let arr):
            guard let arr = arr as? [Date] else {
                XCTFail("Unpacking data is not [Date]: \(arr)")
                return
            }
            XCTAssertEqual(arr.count, 1)
            XCTAssertEqual(Double(arr[0].timeIntervalSince1970), Double(date))
        case .failure(let error):
            XCTFail("Unpacking error: \(error)")
        }
    }
}
