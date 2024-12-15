

import Foundation
import SwiftSyntax
import SwiftParser
import SwiftSyntaxBuilder



public class SwiftPackage: Decodable {
    
    public var name: String
    public var products: [Product]
    public var targets: [any PackageTargetProtocol]
    public var dependencies: [Dependency]
    public var version: String
    
    public required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(String.self, forKey: .name)
        products = try c.decode([Product].self, forKey: .products)
        dependencies = try c.decode([Dependency].self, forKey: .dependencies)
        targets = try! c.decode(forKey: .targets)
        version = try c.decode(String.self, forKey: .version)
    }
    
    
}

extension SwiftPackage {
    enum CodingKeys: CodingKey {
        case name
        case products
        case targets
        case dependencies
        case version
    }
}



public extension SwiftPackage {
    struct Product: Decodable {
        let name: String
        let targets: [String]
        
        var expr: ExprSyntax {
            let _targets: ArrayElementListSyntax = .init(expressions: targets.map({"\(literal: $0)"}))
            return ".library(name: \(literal: name), targets: [\(_targets)])"
        }
        public var arrayElement: ArrayElementSyntax {
            .init(expression: expr)
        }
    }
    struct Dependency: Decodable {
        public enum VersionType: String, Decodable {
            case extact
            case upToNextMinor
            case upToNextMajor
        }
        
        let type: VersionType
        let url: String
        let version: String
        
        var expr: ExprSyntax {
            switch type {
            case .extact:
                ".package(url: \(literal: url), from: \(literal: version))"
            case .upToNextMinor:
                ".package(url: \(literal: url), .upToNextMinor(\(literal: version)))"
            case .upToNextMajor:
                ".package(url: \(literal: url), .upToNextMajor(\(literal: version)))"
            }
        }
        
        public var arrayElement: ArrayElementSyntax {
            .init(expression: expr)
        }
    }
    
    
    
}

extension SwiftPackage: CustomStringConvertible {
    
    var macOS: Bool { false }
    
    public var source: SourceFileSyntax {
        let deps: ArrayElementListSyntax = .init {
            for dependency in dependencies {
                dependency.arrayElement.with(\.leadingTrivia, .newline)
            }
        }
        let prods: ArrayElementListSyntax = .init {
            for product in products {
                product.arrayElement
            }
        }
        let _targets: ArrayElementListSyntax = .init {
            for target in targets {
                target.arrayElement.with(\.leadingTrivia, .newline)
            }
        }
        return """
        // swift-tools-version: 5.9

        import PackageDescription

        let package = Package(
            name: \(literal: name),
            platforms: [.iOS(.v13)\(raw: (macOS ? ", .macOS(.v11)" : ""))],
            products: [
                \(prods)
            ],
            dependencies: [\(deps)\n],
            targets: [\(_targets)\n]
        )

        """
    }
    
    public var description: String {
        source.formatted().description
    }
}








