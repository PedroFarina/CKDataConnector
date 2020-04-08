//
//  File.swift
//  
//
//  Created by Pedro Giuliano Farina on 08/04/20.
//

import CloudKit

public enum DataActionAnswer {
    case fail(error: CKError, description: String)
    case successful
}

public enum DataFetchAnswer {
    case fail(error: CKError, description: String)
    case successful(results: [CKRecord])
    case successfulWith(result: Any?)
}

