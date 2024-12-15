import Foundation

enum PackageTargetType: String, Decodable {
    case target
    case binary
}

enum PackageTargetData: CodingKey {
    case type
    case data
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
        return switch try nested.decode(String.self, forKey: .type) {
        case "string":
            try nested.decode(String.self, forKey: .data)
        default:
            try nested.decode(PackageTarget.Dependency.self, forKey: .data)
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
