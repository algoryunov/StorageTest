//
//  SqliteDataStorage.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import Foundation
import SQLite

class SqliteDataStorage: DataStorageProtocol {

    var type: DatabaseType {
        get {
            return .sqlite
        }
    }

    var isIndexed: Bool {
        get {
            return false
        }
    }

    func fetchCurrentEntitiesCount() -> Int {
        let persons = Table("persons")
        let count = try? self.connection?.scalar(persons.count)
        return count ?? 0
    }
  
    func store(_ entities: [Person], _ useTransactions: Bool) -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        guard let connection = self.connection else {
            result.overallResult = .failure
            result.message = "Connection cannot be opened"
            return result
        }

        let executeSearchClosure = {
            let persons = Table("persons")
            let id = Expression<Int64>("id")
            let firstName = Expression<String>("firstName")
            let lastName = Expression<String>("lastName")
            let birthDateTime = Expression<Double>("birthDateTime")
            
            try connection.transaction {
                for person in entities {
                    let insert = persons.insert(
                        id            <- Int64(person.id),
                        firstName     <- person.firstName,
                        lastName      <- person.lastName,
                        birthDateTime <- person.birthDateTime)
                    let _ = try connection.run(insert)
                }
            }
            
            let newCount = self.fetchCurrentEntitiesCount()
            result.message = "New Entities Count: \(newCount)"
        }
        
        do {
            if useTransactions {
                try connection.transaction {
                    try executeSearchClosure()
                }
            }
            else {
                try executeSearchClosure()
            }
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }

        return result
    }
    
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>) {
        let result = DataStorageOperationResult()
        guard let connection = self.connection else {
            result.overallResult = .failure
            result.errorMessage = "Connection cannot be opened"
            return (result, [Person]())
        }

        var query = "SELECT id, firstName, lastName, birthDateTime FROM persons"
        if filter.count > 0 {
            query = "\(query) WHERE \(filter)"
        }

        var persons = [Person]()
        do {
            let stmt = try connection.prepare(query)
            for row in stmt {
                let person = Person()
                person.id = row[0] as? Int32 ?? 0
                person.firstName = row[1] as? String  ?? "John"
                person.lastName = row[2] as? String ?? "Doe"
                person.birthDateTime = row[3] as? Double ?? 123.0
                persons.append(person)
            }
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }

        return (result, persons)
    }
    
    func clearAll() -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        guard let connection = self.connection else {
            result.overallResult = .failure
            result.errorMessage = "Connection cannot be opened"
            return result
        }

        do {
            let persons = Table("persons")
            let operations = Table("operations")

            try connection.run(persons.delete())
            try connection.run(operations.delete())
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }
        
        return result
    }
    
    func storeOperationResult(_ result: DataStorageOperationResult) {
        do {
            let operations = Table("operations")
            let duration = Expression<Double>("duration")
            let message = Expression<String>("message")
            let operationType = Expression<Int64>("operationType")
            let overallResult = Expression<Int64>("overallResult")
                let insert = operations.insert(
                    duration      <- result.duration,
                    message       <- result.message,
                    operationType <- Int64(result.operationType.rawValue),
                    overallResult <- Int64(result.overallResult == .success ? 1 : 0))
                let _ = try self.connection?.run(insert)
        }
        catch {
            print("save failed")
        }
    }
    
    func getSearchQueryHelp() -> String {
        return "firstName like '%mi%'"
    }
    
    // MARK: Statistic

    func getDatabaseFilePaths() -> [URL] {
        let url = URL(fileURLWithPath: SqliteDataStorage.pathToDatabase)
        return [ url ]
    }
    
    func getNumberOfOperations(withType type: DatabaseOperationType) -> Int {
        let operations = Table("operations")
        let count = try? self.connection?.scalar(operations.count)
        return count ?? 0
    }
    
    func getAverageDurationOfOperation(withType type: DatabaseOperationType) -> Double {
        let operations = Table("operations")
        let duration = Expression<Double>("duration")
        let average = try? self.connection?.scalar(operations.select(duration.average))
        return average ?? 0.0
    }
    
    // MARK: Other
    
    func changeIndexedState(_ newState: Bool) -> DataStorageOperationResult {
        return DataStorageOperationResult()
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

    private var connection: Connection? {
        get {
            let isDatabaseExists = FileManager.default.fileExists(atPath: SqliteDataStorage.pathToDatabase)
            
            let db = try? Connection(SqliteDataStorage.pathToDatabase)
            db?.busyTimeout = 5
            db?.busyHandler({ tries in
                if tries >= 3 {
                    return false
                }
                return true
            })

            if isDatabaseExists == false, db != nil {
                do {
                    try self.createTables(db!)
                }
                catch {
                    print("tables are not created")
                }
            }

            return db
        }
    }
    
    private func createTables(_ connection: Connection) throws {
        let persons = Table("persons")
        let id = Expression<Int64>("id")
        let firstName = Expression<String>("firstName")
        let lastName = Expression<String>("lastName")
        let birthDateTime = Expression<Double>("birthDateTime")
        
        try connection.run(persons.create { t in
            t.column(id, primaryKey: true)
            t.column(firstName)
            t.column(lastName)
            t.column(birthDateTime)
        })

        
        let operations = Table("operations")
        let duration = Expression<Double>("duration")
        let message = Expression<String>("message")
        let operationType = Expression<Int64>("operationType")
        let overallResult = Expression<Int64>("overallResult")
        try connection.run(operations.create { t in
            t.column(duration)
            t.column(message)
            t.column(operationType)
            t.column(overallResult)
        })
    }
}
