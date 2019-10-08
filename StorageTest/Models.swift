//
//  Models.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

class Person {
    var id: Int32     = 0
    var firstName     = ""
    var lastName      = ""
    var birthDateTime = 0.0
}

class Company {
    var id   = 0
    var name = ""
}

// MARK: Database Statistic

class DatabaseInfo {
    var numberOfStoredEntities = 0
    var databaseFileSize = 0.0
    var operationsStatistic = [OperationStatistic]()
    var description: String {
        get {
            var string = """
                         Number of stored entities: \(self.numberOfStoredEntities)
                         Database File Size (mb): \(self.databaseFileSize)
                         """
            for operationStatistic in operationsStatistic {
                string.append("\n\(operationStatistic.description)")
            }
            return string
        }
    }
}

class OperationStatistic {
    var type = DatabaseOperationType.read
    var averageDuration = 0.0
    var numberOfOperations: Int = 0
    
    var description: String {
        get {
            let typeDescription = self.type.description.align(.Right, 16)
            let count = "Count: \(self.numberOfOperations)".align(.Center, 12)
            let duration = "Avg Duration: \(self.averageDuration.format(f: ".4"))".align(.Center, 22)
            return "::\(typeDescription):::\(count):::\(duration)::"
        }
    }
}

enum DatabaseType {
    case coreData, realm, sqlite
    
    var description : String {
        switch self {
        case .coreData: return "Core Data"
        case .realm:    return "Realm"
        case .sqlite:   return "Sqlite"
        }
    }
}

enum OverallResult {
    case success, failure
    var description : String {
        switch self {
        case .success: return "Success"
        case .failure: return "Failure"
        }
    }
}

enum DatabaseOperationType: Int16, CaseIterable {
    case read  = 0
    case write = 1
    case clear = 2
    case readStatistic = 3
    case indexing = 4
    
    var description : String {
        switch self {
        case .read:   return "Read"
        case .write:  return "Write"
        case .clear:  return "Clear"
        case .readStatistic: return "Read Statistic"
        case .indexing: return "Indexing"
        }
    }
}

class DataStorageOperationResult {
    var duration = 0.0
    var overallResult = OverallResult.success
    var message  = ""
    var operationType = DatabaseOperationType.read
    var storageType = DatabaseType.coreData
    var errorMessage: String?
    
    var description: String {
        get {
            var string = "Storage Type: \(self.storageType.description)\nOperation Type: \(self.operationType)"
            if let error = errorMessage {
                string = "\(string)\nError Occurred! \(error)"
            }
            else {
                string = "\(string)\nDuration: \(self.duration.format(f: ".4"))\nResult: \(self.overallResult.description)"

                if message.count > 0 {
                    string = "\(string)\nMessage: \(self.message)"
                }
            }
            
            return string
        }
    }
}

struct DataStorageConfiguration {
    var shouldUseTransactions = false
    var isIndexed = false
}
