import XCTest

@testable import Errors

// swiftlint:disable force_unwrapping
final class ErrorsTests: XCTestCase {
    func testMirrorErrorProvidesDetailsOnErrorConformingToDetailedStringConvertible() {
        XCTAssertEqual(Inheriting_MirrorableError(reason: "123").described, "Custom description with reason: 123")
    }
    
    func testMirrorErrorProvidesDetailsOnBaseClass() {
        XCTAssertEqual(Non_Mirrorable_Via_Inheritance_Error(reason: "123").described, "Non_Mirrorable_Via_Inheritance_Error reason: 123")
    }
    
    func testMirrorErrorDoesNotProvideDetailsOnInheritedError() {
        XCTAssertEqual(
            Inheriting_Non_Mirrorable_Error(reason: "123").described,
            "Inheriting_Non_Mirrorable_Error" // notice: no "reason"
        )
    }
    
    func test_DetailedError_IncludesMasked_Bytes_Dates_UUIDs_And_MemoryLocations() {
        let causeString = "123 bytes, MemLocation: 0x123456af, uuid: \(UUID().uuidString), date: \(Date.now.ISO8601Format())"
        let errorDescribed = DetailedError(rootCause: JZDError.illegalArgument(causeString, .details()), details: .details()).described!
        
        XCTAssertTrue(errorDescribed.contains("### bytes"))
        XCTAssertTrue(errorDescribed.contains("date: ####-##-##T##:##:##+####"))
        XCTAssertTrue(errorDescribed.contains("uuid: ########-####-####-####-############"))
        XCTAssertTrue(errorDescribed.contains("MemLocation: 0x######"))
        
        XCTAssertTrue(errorDescribed.contains(causeString))
    }
}

class Non_Mirrorable_Via_Inheritance_Error: Error {
    let reason: String
    
    init(reason: String) {
        self.reason = reason
    }
}

class Inheriting_Non_Mirrorable_Error: Non_Mirrorable_Via_Inheritance_Error {}

class MirrorableError: Error, DetailedStringConvertible {
    let reason: String
    
    init(reason: String) {
        self.reason = reason
    }
    
    var description: String {
        "Custom description with reason: " + reason
    }
}

class Inheriting_MirrorableError: MirrorableError {}
