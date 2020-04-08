import  CloudKit

public enum DatabaseType {
    case Private
    case Shared
    case Public
}

@available(watchOS 3.0, *)
public final class Connector {
    private init() {
    }

    public static var container: CKContainer = CKContainer.default()
    private static var privateDB: CKDatabase {
        return container.privateCloudDatabase
    }
    @available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *)
    private static var sharedDB: CKDatabase {
        return container.sharedCloudDatabase
    }
    private static var publicDB: CKDatabase {
        return container.publicCloudDatabase
    }
    private static func getDB(from dataType: DatabaseType) -> CKDatabase {
        switch dataType {
        case .Private:
            return privateDB
        case .Shared:
            if #available(iOS 10.0, tvOS 10.0, watchOS 3.0, macOS 10.12, *) {
                return sharedDB
            } else {
                return publicDB
            }
        case .Public:
            return publicDB
        }
    }

    // MARK: Saving Object
    public static func saveObject(database: DatabaseType, object: EntityObject,
                                    completionHandler: ((DataActionAnswer) -> Void)?) {
        getDB(from: database).save(object.record) { (_, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler?(.fail(error: error, description:
                        "CloudKit Saving Error - Save: \(String(describing: error))"))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler?(.successful)
            }
            return
        }
    }

    // MARK: Saving Objects
    @available(iOS 10.0, *)
    public static func saveData(database: DatabaseType, entitiesToSave: [EntityObject]) {
        saveData(database: database, entitiesToSave: entitiesToSave, entitiesToDelete: [])
    }
    @available(iOS 10.0, *)
    public static func deleteData(database: DatabaseType, entitiesToDelete: [EntityObject]) {
        saveData(database: database, entitiesToSave: [], entitiesToDelete: entitiesToDelete)
    }

    @available(iOS 10.0, *)
    public static func saveData(database: DatabaseType, entitiesToSave: [EntityObject], entitiesToDelete: [EntityObject]) {

        var savingRecords: [CKRecord] = []
        for obj in entitiesToSave {
            savingRecords.append(obj.record)
        }

        var deletingRecords: [CKRecord.ID] = []
        for obj in entitiesToDelete {
            deletingRecords.append(obj.record.recordID)
        }

        let operation: CKModifyRecordsOperation = CKModifyRecordsOperation(
            recordsToSave: savingRecords, recordIDsToDelete: deletingRecords)
        operation.savePolicy = .changedKeys
        getDB(from: database).add(operation)
    }

    // MARK: Deleting Object
    public static func deleteObject(database: DatabaseType, object: EntityObject,
                               completionHandler: ((DataActionAnswer) -> Void)?) {
        getDB(from: database).delete(withRecordID: object.record.recordID) { (_, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler?(.fail(error: error, description:
                        "CloudKit Deleting Error - Delete: \(String(describing: error))"))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler?(.successful)
            }
            return
        }
    }

    // MARK: Fetching
    public static func fetchUserID(completionHandler: @escaping (DataFetchAnswer) -> Void) {
        container.fetchUserRecordID { (userID, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "CloudKit Query Error - Fetch: \(String(describing: error))"))
                }
                return
            }
            DispatchQueue.main.async {
                completionHandler(.successfulWith(result: userID))
            }
        }
    }

    public static func fetch(recordType: String, database: DatabaseType, completionHandler: @escaping (DataFetchAnswer) -> Void) {
        let predicate = NSPredicate(value: true)
        fetch(query: CKQuery(recordType: recordType, predicate: predicate), database: database, completionHandler: completionHandler)
    }

    public static func fetch(query: CKQuery, database: DatabaseType, completionHandler: @escaping (DataFetchAnswer) -> Void ) {
        getDB(from: database).perform(query, inZoneWith: nil) { (results, error) in
            if let error = error as? CKError {
                DispatchQueue.main.async {
                    completionHandler(.fail(error: error, description:
                        "CloudKit Query Error - Fetch: \(String(describing: error))"))
                }
                return
            }

            DispatchQueue.main.async {
                completionHandler(.successful(results: results ?? []))
            }
        }
    }
}
