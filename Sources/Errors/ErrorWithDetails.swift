import Foundation

/// An interface to represent an error with tracing details
public protocol ErrorWithDetails: Error {
    var details: ErrorDetails { get }
}

/// An interface to represent an error that was caused by another error.
public protocol ErrorWithRootCause: Error {
    var rootCause: Error { get }
}

/// A detailed error caused by another error
open class DetailedError: ErrorWithDetails, ErrorWithRootCause {
    public let rootCause: Error
    public let details: ErrorDetails
    
    public init(rootCause: Error, details: ErrorDetails) {
        self.rootCause = rootCause
        self.details = details
    }
}

/// An Error that represents an external dependency failure as the root cause.
public final class DependencyError: DetailedError {}
