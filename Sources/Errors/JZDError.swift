import Foundation

public typealias ResponseData = (data: Data, response: URLResponse, request: URLRequest, responseTimeMs: Int)

/// A helpful array of commonly needed errors
public enum JZDError: ErrorWithDetails {
    case illegalArgument(String, ErrorDetails)
    case illegalState(String, ErrorDetails)
    case invalidURL(String, ErrorDetails)
    case runtime(String, ErrorDetails)
    case statusCode(Int, ResponseData, ErrorDetails)
    
    /// A convenience variable to pull the error details from the enum cases
    public var details: ErrorDetails {
        switch self {
        case let .illegalArgument(_, errorDetails),
            let .illegalState(_, errorDetails),
            let .invalidURL(_, errorDetails),
            let .runtime(_, errorDetails),
            let .statusCode(_, _, errorDetails):
            return errorDetails
        }
    }
}

public extension JZDError {
    static func illegalArgument(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        traceId: String? = nil
    ) -> JZDError {
        .illegalArgument(message, .details(file: file, function: function, line: line, traceId: traceId))
    }
    
    static func invalidURL(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        traceId: String? = nil
    ) -> JZDError {
        .invalidURL(message, .details(file: file, function: function, line: line, traceId: traceId))
    }
    
    static func runtime(
        _ message: String,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        traceId: String? = nil
    ) -> JZDError {
        .runtime(message, .details(file: file, function: function, line: line, traceId: traceId))
    }
    
    static func statusCode(
        _ code: Int,
        response: ResponseData,
        file: String = #fileID,
        line: Int = #line,
        function: String = #function,
        traceId: String? = nil
    ) -> JZDError {
        .statusCode(code, response, .details(file: file, function: function, line: line, traceId: traceId))
    }
}
// swiftlint:disable syntactic_sugar
/// Unwrap or throw
/// - Parameters:
///   - left: An optional value
///   - right: An error to throw if the optional value isn't present
/// - Throws: An Error
/// - Returns: The unwrapped value
infix operator ?! : TernaryPrecedence
func ?!<T>(_ left: Optional<T>, right: Error) throws -> T {
    guard let value = left else { throw right }
    return value
}
