//
//  SqliteDataStorage.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import SQLite3

class SqliteDataStorage: DataStorageProtocol {

    var type: DatabaseType {
        get {
            return .sqlite
        }
    }

    func fetchCurrentEntitiesCount() -> Int32 {
        return 0
    }

    func getTotalEntitiesCount() -> DataStorageOperationResult {

        return DataStorageOperationResult()
    }
    
    func store(_ entities: [Person]) -> DataStorageOperationResult {
        return DataStorageOperationResult()
    }
    
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>) {
        return (DataStorageOperationResult(), [Person]())
    }
    
    func getStatistics() -> DatabaseInfo {
        return DatabaseInfo()
    }

    func clearAll() -> DataStorageOperationResult {
        return DataStorageOperationResult()
    }
    
    func storeOperationResult(_ result: DataStorageOperationResult) {
        
    }
    
    func getSearchQueryHelp() -> String {
        return ""
    }
    
    // MARK: Statistic
    
    func fetchCurrentEntitiesCount() -> Int {
        return 0
    }
    
    func getDatabaseFilePaths() -> [URL] {
        return []
    }
    
    func getNumberOfOperations(withType type: DatabaseOperationType) -> Int {
        return 0
    }
    
    func getAverageDurationOfOperation(withType type: DatabaseOperationType) -> Double {
        return 0.0
    }

    // MARK: Private
    
    private class var pathToDatabase: String {
        get {
            let path = NSSearchPathForDirectoriesInDomains(
                .documentDirectory, .userDomainMask, true
                ).first!
            return "\(path)/db.sqlite"
        }
    }

    private class var connection: Connection? {
        get {
            let db = try? Connection(SqliteDataStorage.pathToDatabase)
            db?.busyTimeout = 5
            db?.busyHandler({ tries in
                if tries >= 3 {
                    return false
                }
                return true
            })
            return db
        }
    }
    
}
