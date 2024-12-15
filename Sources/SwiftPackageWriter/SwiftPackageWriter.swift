// The Swift Programming Language
// https://docs.swift.org/swift-book
// 
// Swift Argument Parser
// https://swiftpackageindex.com/apple/swift-argument-parser/documentation

import ArgumentParser
import PathKit
import Foundation
import SwiftPackage

@main
struct SwiftPackageWriter: AsyncParsableCommand {
    
    static var configuration: CommandConfiguration { .init(
        subcommands: [
            Create.self,
            Update.self
        ]
    )}
    
}

extension Path: @retroactive ExpressibleByArgument {
    public init?(argument: String) {
        self = .init(argument)
    }
}

extension SwiftPackageWriter {
    
    struct Create: AsyncParsableCommand {
        
        @Argument
        var json_file: Path
        
        @Option(name: .shortAndLong)
        var output: Path?
        
        func run() async throws {
            
            let json_data = try json_file.read()
            let package = try JSONDecoder().decode(SwiftPackage.self, from: json_data)
            
            print(package)
            
            
        }
    }
    
    struct Update: AsyncParsableCommand {
        @Argument
        var file: Path
    }
    
}
