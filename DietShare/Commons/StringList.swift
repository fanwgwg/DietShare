//
//  IDList.swift
//  DietShare
//
//  Created by Shuang Yang on 28/3/18.
//  Copyright © 2018 com.marvericks. All rights reserved.
//

import Foundation
import SQLite

/**
 * Overview:
 *
 * A wrapper class for a list of string.
 *
 * Specification fields:
 *
 * - type: ListType - indicate the type of element included in the list
 *  - Constraints: limited to values of enum ListType
 * - list: Set<String> - a set of string included in this wrapper class
 */

class StringList: Equatable, Codable {
    
    private var type: ListType
    
    private var list: Set<String>
    
    enum CodingKeys: String, CodingKey {
        case type
        case list
    }
    
    init(_ type: ListType, _ list: Set<String>) {
        self.type = type
        self.list = list
    }
    
    convenience init(_ type: ListType) {
        let list = Set<String>()
        self.init(type, list)
    }
    
    public func getType() -> ListType {
        return self.type
    }
    
    public func getListAsArray() -> [String] {
        var returnList = [String]()
        returnList.append(contentsOf: self.list)
        return returnList
    }
    
    public func getListAsSet() -> Set<String> {
        return self.list
    }
    
    public func setList(_ newList: Set<String>) {
        self.list = newList
    }
    
    public func addEntry(_ newEntry: String) {
        self.list.insert(newEntry)
    }
    public func addEntries(_ newEntries: [String]) {
        for entry in newEntries {
            self.list.insert(entry)
        }
    }
    
    static func ==(lhs: StringList, rhs: StringList) -> Bool {
        return lhs.type == rhs.type && lhs.list == rhs.list
    }
    
    required init(from decoder: Decoder) throws {
        let value = try decoder.container(keyedBy: CodingKeys.self)
        let typeRawValue = try value.decode(String.self, forKey: .type)
        guard let idType = ListType(rawValue: typeRawValue) else {
            fatalError("Error decoding type")
        }
        self.type = idType
        self.list = try value.decode(Set<String>.self, forKey: .list)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.type.rawValue, forKey: .type)
        try container.encode(self.list, forKey: .list)
    }
}

extension StringList: Value {
    public class var declaredDatatype: String {
        return Blob.declaredDatatype
    }
    public class func fromDatatypeValue(_ blobValue: Blob) -> StringList {
        guard let list = try? JSONDecoder().decode(StringList.self, from: Data.fromDatatypeValue(blobValue)) else {
            fatalError("IDList not correctly decoded")
        }
        return list
    }
    public var datatypeValue: Blob {
        guard let listData = try? JSONEncoder().encode(self) else {
            fatalError("IDList not correctly encoded")
        }
        return listData.datatypeValue
    }
}
