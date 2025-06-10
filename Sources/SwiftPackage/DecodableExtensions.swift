import Foundation

enum PackageTargetType: String, Decodable {
    case target
    case binary
}

enum TargetDependencyType: String, Decodable {
    case string
    case dependency
}

enum PackageTargetData: CodingKey {
    case type
    case data
    case condition
}

extension UnkeyedDecodingContainer {
    
    mutating func decode() throws -> any PackageTargetProtocol {
        let nested = try nestedContainer(keyedBy: PackageTargetData.self)
        return switch try! nested.decode(PackageTargetType.self, forKey: .type) {
        case .target:
            try! nested.decode(PackageTarget.self, forKey: .data)
        case .binary:
            try! nested.decode(PackageBinaryTarget.self, forKey: .data)
        }
    }
    
    mutating func decode() throws -> [any PackageTargetProtocol] {
        var output: [any PackageTargetProtocol] = []
        while !isAtEnd {
            output.append(try decode())
        }
        return output
    }
    
    mutating func decode() throws -> any TargetDependency {
        let nested = try nestedContainer(keyedBy: PackageTargetData.self)
        switch try nested.decode(TargetDependencyType.self, forKey: .type) {
        case .string:
            let name = try nested.decode(String.self, forKey: .data)
            if let condition = try nested.decode([String : String]?.self, forKey: .condition) {
                return PackageTarget.Dependency(
                    name: name,
                    package: name,
                    type: .target,
                    condition: condition
                )
            }
            return name
        case .dependency:
            return try nested.decode(PackageTarget.Dependency.self, forKey: .data)
        }
    }
    
    mutating func decode() throws -> [any TargetDependency] {
        var output: [any TargetDependency] = []
        while !isAtEnd {
            output.append(try decode())
        }
        return output
    }
    
}

extension KeyedDecodingContainer {
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> [(any PackageTargetProtocol)] {
        var nested = try nestedUnkeyedContainer(forKey: key)
        return try nested.decode()
    }
    
    public func decode(forKey key: KeyedDecodingContainer<K>.Key) throws -> [(any TargetDependency)] {
        var nested = try nestedUnkeyedContainer(forKey: key)
        
        return try nested.decode()
    }
    
    public func decode<T>(forKey key: KeyedDecodingContainer<K>.Key) throws -> T where T : Decodable {
        try decode(T.self, forKey: key)
    }
}

extension KeyedDecodingContainer where Key == PackageTargetData {
    
    mutating func decode() throws -> any PackageTargetProtocol {
        return switch try decode(PackageTargetType.self, forKey: .type) {
        case .target:
            try decode(PackageTarget.self, forKey: .data)
        case .binary:
            try decode(PackageBinaryTarget.self, forKey: .data)
        }
    }
    
}
