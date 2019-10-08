//
//  RealmDataStorage.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import RealmSwift

class RealmDataStorage: DataStorageProtocol {

    private var realm: Realm {
        get {
            return try! Realm()
        }
    }

    // MARK: DataStorageProtocol

    var type: DatabaseType {
        get {
            return .realm
        }
    }

    var isIndexed: Bool {
        get {
            return false
        }
    }
    
    func fetchCurrentEntitiesCount() -> Int {
        let count = self.realm.objects(RealmPerson.self).count
        return count
    }

    func store(_ entities: [Person], _ useTransactions: Bool) -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        do {
            try realm.write {
                for person in entities {
                    let realmPerson = RealmPerson.create(fromPerson: person)
                    realm.add(realmPerson)
                }
            }

            let newCount = self.fetchCurrentEntitiesCount()
            result.message = "New Entities Count: \(newCount)"
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }
        return result
    }
    
    func search(_ filter: String) -> (DataStorageOperationResult, Array<Person>) {
        let result = DataStorageOperationResult()
        var predicate: NSPredicate?
        var errorMessage: String?
        if filter.count > 0 {
            ObjC.try({
                predicate = NSPredicate(format: filter)
            }, catch: { exception in
                errorMessage = exception.description
            })
        }

        if let errorMessage = errorMessage {
            result.overallResult = .failure
            result.errorMessage = errorMessage
            return (result, [])
        }

        var realmObjects = self.realm.objects(RealmPerson.self)
        if let predicate = predicate {
            realmObjects = realmObjects.filter(predicate) // realm docs says I can do this is *this* way
        }

        var persons = [Person]()
        for realmPerson in realmObjects {
            persons.append(realmPerson.convertToPerson())
        }

        return (result, persons)
    }

    func clearAll() -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        do {
            try realm.write {
                realm.deleteAll()
            }
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }
        return result
    }
    
    func storeOperationResult(_ result: DataStorageOperationResult) {
        do {
            try realm.write {
                let realmOperationResult = RealmOperationResult.create(fromOperationResult: result)
                realm.add(realmOperationResult)
            }
        }
        catch {
            result.overallResult = .failure
            result.errorMessage = error.localizedDescription
        }
    }
    
    func getSearchQueryHelp() -> String {
        return """
        Field names: id (Int), firstName (String), lastName (String), birthDateTime (Double)
        NSPredicate-compatible contructions can be used as a filter. Examples of search:
        firstName == Smith
        (lastName CONTAINS[cd] 'mi') OR (firstName LIKE 'mi%') // [cd] stands for "Case & Diacritic insensitive"
        birthDateTime > 12345
        """
    }
    
    // MARK: Statistic


    func getDatabaseFilePaths() -> [URL] {
        if let url = realm.configuration.fileURL {
            return [url]
        }
        return []
    }

    func getNumberOfOperations(withType type: DatabaseOperationType) -> Int {
        let objects = self.realm.objects(RealmOperationResult.self).filter { realmOperationResult -> Bool in
            return realmOperationResult.operationType == type.rawValue
        }
        return objects.count
    }

    func getAverageDurationOfOperation(withType type: DatabaseOperationType) -> Double {
        return self.realm.objects(RealmOperationResult.self).filter(NSPredicate(format: "operationType == \(type.rawValue)")).average(ofProperty: "duration") ?? 0.0
    }
    
    // MARK: Other

    func changeIndexedState(_ newState: Bool) -> DataStorageOperationResult {
        return DataStorageOperationResult()
    }

}
