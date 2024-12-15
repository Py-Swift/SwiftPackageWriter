import Foundation

import SwiftSyntax
import SwiftSyntaxBuilder

extension ArrayElementSyntax {
    static func binaryTarget(name: String, url: String, checksum: String) -> Self {
        let call: ExprSyntax = """
        .binaryTarget(
            name: \(literal: name), 
            url: \(literal: url), 
            checksum: \(literal: checksum)
        )
        """
        return .init(
            leadingTrivia: .newline,
            expression: call
        )
        
    }
    static func binaryTarget(owner: String, repo: String, version: String, file_name: String, sha: String) -> Self {
        let call: ExprSyntax = """
        .binaryTarget(
            name: \(literal: file_name), 
            url: "https://github.com/\(raw: owner)/\(raw: repo)/releases/download/\(raw: version)/\(raw: file_name).zip", checksum: \(literal: sha)
        )
        """
        return .init(
            leadingTrivia: .newline + .tab,
            expression: call
        )
        
    }
    static func copyResource(_ src: String) -> Self {
        let call = ExprSyntax(stringLiteral: """
            .copy("\(src)")
            """)
        return .init(expression: call)
            .with(\.leadingTrivia, .newline + .tab)
            //.withLeadingTrivia(.newline + .tab)
    }
}
