//
//  PackageBinaryTarget.swift
//  SwiftPackageWriter
//
//  Created by CodeBuilder on 14/12/2024.
//
import Foundation
import PathKit
import SwiftSyntax
import SwiftSyntaxBuilder

public protocol PackageTargetProtocol: Decodable {
    var arrayElement: ArrayElementSyntax { get }
}

public protocol TargetDependency: Decodable {
    var arrayElement: ArrayElementSyntax { get }
}

extension String: TargetDependency {
    public var arrayElement: ArrayElementSyntax {
        .init(expression: ExprSyntax.init(stringLiteral: "\"\(self)\""))
    }
}


public struct PackageTarget: PackageTargetProtocol {
    
    
    
    let name: String
    let dependencies: [any TargetDependency]
    let linker_settings: [LinkedSetting]
    let resources: [Resource]
    let plugins: [Plugin]
    
    public init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        name = try c.decode(forKey: .name)
        dependencies = try c.decode(forKey: .dependencies)
        linker_settings = try c.decode(forKey: .linker_settings)
        resources = try c.decode(forKey: .resources)
        plugins = try c.decode(forKey: .plugins)
    }
    

    
    private enum CodingKeys: CodingKey {
        case name
        case dependencies
        case linker_settings
        case resources
        case plugins
    }
    
 
}

public extension PackageTarget {
    struct Dependency: TargetDependency {
        let name: String
        let package: String
        
        public var arrayElement: ArrayElementSyntax {
            let expr: ExprSyntax = """
            .product(name: \(literal: name), package: \(literal: package))
            """
            return .init(expression: expr)
        }
    }
    
    struct LinkedSetting: Decodable {
        enum Kind: String, Decodable {
            case framework
            case library
        }
        let kind: Kind
        let name: String
        
        public var arrayElement: ArrayElementSyntax {
            let expr: ExprSyntax = switch kind {
            case .framework:
                ".linkedFramework(\(literal: name))"
            case .library:
                ".linkedLibrary(\(literal: name))"
            }
            return .init(expression: expr)
        }
    }
    
    struct Resource: Decodable {
        enum Kind: String, Decodable {
            case copy
            case process
        }
        let kind: Kind
        let path: String
        
        public var arrayElement: ArrayElementSyntax {
            let expr: ExprSyntax = switch kind {
            case .copy:
                ".copy(\(literal: path))"
            case .process:
                ".process(\(literal: path))"
            }
            return .init(expression: expr)
        }
    }
    
    struct Plugin: Decodable {
        let name: String
        let package: String
        
        public var arrayElement: ArrayElementSyntax {
            let expr: ExprSyntax = ".plugin(name: \(literal: name), package: \(literal: package))"
            return .init(expression: expr)
        }
    }
    
    var arrayElement: ArrayElementSyntax {
        let deps: ArrayElementListSyntax = .init {
            for dependency in self.dependencies {
                dependency.arrayElement.with(\.leadingTrivia, .newline + .tabs(2))
            }
        }
        let linkers: ArrayElementListSyntax = .init {
            for linker in self.linker_settings {
                linker.arrayElement.with(\.leadingTrivia, .newline + .tabs(2))
            }
        }
        let res: ArrayElementListSyntax = .init {
            for resource in self.resources {
                resource.arrayElement.with(\.leadingTrivia, .newline + .tabs(2))
            }
        }
        let plugs: ArrayElementListSyntax = .init {
            for resource in self.plugins {
                resource.arrayElement.with(\.leadingTrivia, .newline + .tabs(2))
            }
        }
        let expr: ExprSyntax = """
        .target(
            name: \(literal: name),
            dependencies: [\(deps)\n\t],
            resources: [\(res)\n\t],
            linkerSettings: [\(linkers)\n\t],
            plugins: [\(plugs)]
        )
        """
        return .init(expression: expr)
    }
    
}

public struct PackageBinaryTarget: PackageTargetProtocol {
    public let name: String
    public let url: String
    public let checksum: String
}

extension PackageBinaryTarget {
    public var arrayElement: ArrayElementSyntax {
        .binaryTarget(name: name, url: url, checksum: checksum)
    }
}
