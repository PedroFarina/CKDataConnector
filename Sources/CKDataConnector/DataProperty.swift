//
//  DataProperty.swift
//  
//
//  Created by Pedro Giuliano Farina on 08/04/20.
//

import CloudKit

public enum DataError: LocalizedError {
    case dataParsing
}

public final class DataProperty<T: Equatable> {
    private let record: CKRecord
    private let key: String
    public func getValue() throws -> T {
        guard let val = record.value(forKey: key) as? T else {
            throw DataError.dataParsing
        }
        return val
    }
    public func setValue(_ value: T) {
        record.setValue(value, forKey: key)
    }

    init(record: CKRecord, key: String) {
        self.record = record
        self.key = key
    }
}

extension DataProperty {
    static func == (lhs: T, rhs: DataProperty) -> Bool {
        return lhs == (try? rhs.getValue())
    }
    static func != (lhs: T, rhs: DataProperty) -> Bool {
        return lhs != (try? rhs.getValue())
    }
    static func == (lhs: DataProperty, rhs: T) -> Bool {
        return (try? lhs.getValue()) == rhs
    }
    static func != (lhs: DataProperty, rhs: T) -> Bool {
        return (try? lhs.getValue()) != rhs
    }
}


