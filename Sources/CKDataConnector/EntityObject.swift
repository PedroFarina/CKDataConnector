//
//  EntityObject.swift
//  
//
//  Created by Pedro Giuliano Farina on 08/04/20.
//
import CloudKit

public protocol EntityObject {
    static var recordType: String { get }
    var record: CKRecord { get }
}

