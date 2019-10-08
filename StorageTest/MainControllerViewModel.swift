//
//  MainControllerViewModel.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/27/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import Foundation

typealias UserActionCompletion = (_ logMessage: String) -> ()

class MainControllerViewModel {

    private var dataStorageService: DataStorageServiceProvider

    init(withStorageType type: DatabaseType) {
        self.dataStorageService = DataStorageServiceProvider(withStorageType: type)
    }
    
    func storageTypeChanged(to newStorageType: DatabaseType) {
        if newStorageType != dataStorageService.currentStorageType {
            self.dataStorageService.changeStorage(to: newStorageType)
        }
    }

    func handleGenerateTapped(_ generateCount: Int, completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let currentCount = self.dataStorageService.fetchCurrentEntitiesCount()
            let generateStartTimestamp = Date().timeIntervalSince1970
            let newEntities = DataGenerator.generatePersons(currentCount, generateCount)
            let generationDurationMessage = "Generation duration: \(Date().timeIntervalSince1970 - generateStartTimestamp)"
            let result = self.dataStorageService.store(newEntities)
            let message = "\(generationDurationMessage)\n\(result.description)"
            DispatchQueue.main.async {
                completion(message)
            }
        }
    }

    func handleSearchTapped(_ filter: String?, completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let (result, array) = self.dataStorageService.search(filter ?? "")
            var message = "\(result.description)\nFound enitites: \(array.count)"
            if array.count > 0 {
                let finalIndex = array.count > 10 ? 10 : array.count
                let personsToPrint = array[0...finalIndex].map({ person in
                    return "\(person.firstName) \(person.lastName)"
                })
                message = "\(message)\nFirst \(finalIndex) persons: \n\(personsToPrint.joined(separator: "\n"))"
            }
            DispatchQueue.main.async {
                completion(message)
            }
        }
    }
    
    func handleClearAllTapped(completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let result = self.dataStorageService.clearAll()
            DispatchQueue.main.async {
                completion(result.description)
            }
        }
    }

    func handleGetStatisticsTapped(completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let result = self.dataStorageService.getStatistics()
            DispatchQueue.main.async {
                completion(result.description)
            }
        }
    }
    
    func handlePrintQueryHelperTapped(completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let result = self.dataStorageService.getSearchQueryHelp()
            DispatchQueue.main.async {
                completion(result)
            }
        }
    }
    
    func handleTransactionSwitchStateChanged(_ newState: Bool, completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let result = self.dataStorageService.changeUseTransactionState(newState)
            DispatchQueue.main.async {
                completion(result.description)
            }
        }
    }
    
    func handleIndexSwitchStateChanged(_ newState: Bool, completion: @escaping UserActionCompletion) {
        DispatchQueue.global(qos: .default).async {
            let result = self.dataStorageService.changeIndexedState(newState)
            DispatchQueue.main.async {
                completion(result.description)
            }
        }
    }
    
    func getHelpText() -> String {
        let path = Bundle.main.path(forResource: "help", ofType: "txt")!
        let helpString = try? String(contentsOfFile: path)
        return helpString ?? ""
    }

    func isDatabaseIndexed() -> Bool {
        return false
    }
}
