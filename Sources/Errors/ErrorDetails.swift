import Foundation

/// A model providing detail on where an error was thrown
public struct ErrorDetails: Codable, Equatable {
    /// The file name that threw the error in question
    public let file: String
    
    /// The name of the function that threw the error in question
    public let function: String
    
    /// The line of the file where the error in question was thrown
    public let line: Int
    
    /// A trace identifier that may be associated with the error.
    public let traceId: String?
    
    /// A helper function to quickly create error details
    /// - Parameters:
    ///   - file: The name of the file where this function is called from
    ///   - function: The function name that called this function
    ///   - line: The line of the file where this function was invoked
    ///   - traceId: A trace identifier that could be used to track logs across your system
    /// - Returns: Error details
    public static func details(
        file: String = #fileID,
        function: String = #function,
        line: Int = #line,
        traceId: String? = nil
    ) -> ErrorDetails {
        .init(file: file, function: function, line: line, traceId: traceId)
    }
}
