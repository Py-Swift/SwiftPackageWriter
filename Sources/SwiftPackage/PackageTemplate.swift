import Foundation
import SwiftSyntax
import SwiftSyntaxBuilder



func packageSample(repo: String, macOS: Bool) -> String {
"""
// swift-tools-version: 5.9

import PackageDescription

let package = Package(
    name: "\(repo)",
    platforms: [.iOS(.v13)\(macOS ? ", .macOS(.v11)" : "")],
    products: [

    ],
    dependencies: [

    ],
    targets: [

    ]
)

"""
}


