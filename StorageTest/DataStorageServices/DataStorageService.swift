//
//  DataStorageService.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import Foundation

typealias DataStorageOperationCompletion = (DataStorageOperationResult)

protocol DataStorageServiceProviderProtocol {
    var currentStorageType: DatabaseType { get }

    func fetchCurrentEntitiesCount() -> Int
    func store(_ entities: [Person]) -> DataStorageOperationResult
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>)
    func getStatistics() -> DatabaseInfo
    func clearAll() -> DataStorageOperationResult
}

protocol DataStorageProtocol {
    var type: DatabaseType { get }
    
    func fetchCurrentEntitiesCount() -> Int
    func store(_ entities: [Person]) -> DataStorageOperationResult
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>)
    func clearAll() -> DataStorageOperationResult
    func storeOperationResult(_ result: DataStorageOperationResult)
    func getSearchQueryHelp() -> String

    // Statistic
    func getDatabaseFilePaths() -> [URL]
    func getNumberOfOperations(withType type: DatabaseOperationType) -> Int
    func getAverageDurationOfOperation(withType type: DatabaseOperationType) -> Double
}

class DataStorageServiceProvider: DataStorageServiceProviderProtocol {

    private var currentStorage: DataStorageProtocol

    // MARK: Public

    init(withStorageType type: DatabaseType) {
        self.currentStorage = DataStorageServiceProvider.getStorage(withType: type)
    }
    
    func changeStorage(to type: DatabaseType) {
        self.currentStorage = DataStorageServiceProvider.getStorage(withType: type)
    }

    // MARK: DataStorageServiceProtocol
    
    var currentStorageType: DatabaseType {
        return self.currentStorage.type
    }

    func fetchCurrentEntitiesCount() -> Int {
        return self.currentStorage.fetchCurrentEntitiesCount()
    }
    
    func store(_ entities: [Person]) -> DataStorageOperationResult {
        let startTimestamp = Date.init().timeIntervalSince1970
        let result = self.currentStorage.store(entities)
        result.storageType = self.currentStorage.type
        result.operationType = .write
        result.duration = Date.init().timeIntervalSince1970 - startTimestamp
        if result.overallResult == .success {
            self.currentStorage.storeOperationResult(result)
        }
        return result
    }
    
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>) {
        let startTimestamp = Date.init().timeIntervalSince1970
        let (result, array) = self.currentStorage.search(filter)
        result.storageType = self.currentStorage.type
        result.operationType = .read
        result.duration = Date.init().timeIntervalSince1970 - startTimestamp
        if result.overallResult == .success {
            self.currentStorage.storeOperationResult(result)
        }
        return (result, array)
    }
    
    func getStatistics() -> DatabaseInfo {
        let databaseInfo = DatabaseInfo()
        databaseInfo.databaseFileSize = self.getDatabaseFileSize()
        databaseInfo.numberOfStoredEntities = self.fetchCurrentEntitiesCount()
        for operationType in [ DatabaseOperationType.read, DatabaseOperationType.write ] {
            let statistic = self.captureStatistic(forOperationType: operationType)
            databaseInfo.operationsStatistic.append(statistic)
        }
        return databaseInfo
    }
    
    func clearAll() -> DataStorageOperationResult {
        let startTimestamp = Date.init().timeIntervalSince1970
        let result = self.currentStorage.clearAll()
        result.storageType = self.currentStorage.type
        result.operationType = .clear
        result.duration = Date.init().timeIntervalSince1970 - startTimestamp
        if result.overallResult == .success {
            self.currentStorage.storeOperationResult(result)
        }
        return result
    }
    
    func getSearchQueryHelp() -> String {
        return self.currentStorage.getSearchQueryHelp()
    }

    // MARK: Private

    private class func getStorage(withType type: DatabaseType) -> DataStorageProtocol {
        switch type {
        case .coreData:  return CoreDataDataStorage()
        case .realm:     return RealmDataStorage()
        case .sqlite:    return SqliteDataStorage()
        }
    }
    
    // MARK: Private > Statistic

    private func getDatabaseFileSize() -> Double {
        let allUrls = self.currentStorage.getDatabaseFilePaths()
        var totalSize = 0.0
        let fileManager = FileManager.default
        for url in allUrls {
            if !url.isFileURL {
                continue
            }
            if let size = try? fileManager.attributesOfItem(atPath: url.path)[FileAttributeKey.size] as? NSNumber {
                totalSize += size.doubleValue
            }
        }
        return totalSize / (1024 * 1024)
    }
    
    func captureStatistic(forOperationType type: DatabaseOperationType) -> OperationStatistic {
        let statistic = OperationStatistic()
        statistic.type = type
        statistic.numberOfOperations = self.currentStorage.getNumberOfOperations(withType: type)
        statistic.averageDuration = self.currentStorage.getAverageDurationOfOperation(withType: type)
        return statistic
    }
    
}
