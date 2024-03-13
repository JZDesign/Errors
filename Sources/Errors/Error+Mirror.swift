import Foundation

public extension Error {
    /// Provides a log friendly description of the error
    var described: String? {
        describe(self)
    }
}

public protocol DetailedStringConvertible: CustomStringConvertible {}

// MARK: - Detailed Error description

extension DetailedError: DetailedStringConvertible {
    /// Provides a log friendly description of the error
    ///
    /// Using Swift's ``Mirror`` this variable is a reflective string representation of the error and it's fields.
    ///
    /// **Note**
    public var description: String {
        let mirroredDetails = Mirror(reflecting: details).description
        
        guard let root = describe(rootCause) else {
            return mirroredDetails
        }

        // This presents the details masked first then unmasked afterwards so it's easier to group like messages based on the first N characters. This is done sometimes in Loggly with a derrived field `stack_trace_short`
        var result = "RootCause: \(root.maskUuids().maskBytes().maskIsoDatetimes().maskMemoryLocations())\n\n\(root)\n"
        let detailString = "ErrorDetails: \(mirroredDetails)"
        
        switch (rootCause as? ErrorWithDetails)?.details {
        case details:
            break // do not include the same details twice
        default:
            result += detailString
        }
        return result
    }
}

// MARK: - Helper functions

private func describe(_ value: some Any) -> String? {
    if let value = value as? DetailedStringConvertible {
        return value.description
    }
    return Mirror(reflecting: value).description
}

extension Mirror: DetailedStringConvertible {
    var description: String {
        let title = String(describing: subjectType)
        let children = describeChildren().ignoreEmpty()
        
        if let children {
            return title + " " + children
        }
        
        return title
    }
    
    private func describeChildren() -> String {
        children
            .map { child in
                "\(child.label ?? "unknown key"): \(child.value)"
            }
            .joined(separator: ",")
    }
}

extension String {
    func ignoreEmpty() -> String? {
        isEmpty ? nil : self
    }
}

public extension String {
    private var hexDigit: String { "[0-9a-fA-F]" }
    private var uuidPattern: String { """
    \(hexDigit){8}-\(hexDigit){4}-\(hexDigit){4}-\(hexDigit){4}-\(hexDigit){12}
    """
    }
    
    func maskUuids() -> String { replace(pattern: uuidPattern, with: "########-####-####-####-############") }
    
    private var datetimePattern: String { #"\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:\+[\d.]+|Z)"# }
    func maskIsoDatetimes() -> String { replace(pattern: datetimePattern, with: "####-##-##T##:##:##+####") }
    
    private var memoryLocationPattern: String { #"0x+[0-9a-fA-F]*"# }
    func maskMemoryLocations() -> String { replace(pattern: memoryLocationPattern, with: "0x######") }
    
    private var bytesPattern: String { "[0-9 ]+bytes" }
    func maskBytes() -> String { replace(pattern: bytesPattern, with: "### bytes") }
    
    func replace(pattern: String, with replacement: String) -> String {
        let string: NSMutableString = .init(string: self)
        _ = try? NSRegularExpression(pattern: pattern).replaceMatches(
            in: string,
            range: NSRange(location: 0, length: count),
            withTemplate: replacement
        )
        
        return String(string)
    }
}
