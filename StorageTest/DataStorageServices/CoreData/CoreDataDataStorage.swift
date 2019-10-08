//
//  CoreDataDataStorage.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import CoreData

class CoreDataDataStorage: DataStorageProtocol {

    var type: DatabaseType {
        get {
            return .coreData
        }
    }

    var isIndexed: Bool {
        get {
            return false
        }
    }

    func fetchCurrentEntitiesCount() -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDPerson")
        let count = try? self.persistentContainer.viewContext.count(for: request)
        return Int(count ?? 0)
    }

    func store(_ entities: [Person], _ useTransactions: Bool) -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        let context = self.persistentContainer.newBackgroundContext()
        for person in entities {
            if let cdPerson = NSEntityDescription.insertNewObject(forEntityName: "CDPerson",
                                                                  into: context) as? CDPerson {
                cdPerson.id = person.id
                cdPerson.firstName = person.firstName
                cdPerson.lastName = person.lastName
                cdPerson.birthDateTime = person.birthDateTime
            }
        }
        do {
            try context.save()

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
        // NOTE: I intentionnaly did not optimize the code inside of this method in order to show how
        // ugly looks wrapping Swift methods into both Swift do-catch and ObjC try-catch blocks

        let result = DataStorageOperationResult()
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDPerson")
        var persons = [Person]()
        
        var errorMessage: String?

        if filter.count > 0 {
            ObjC.try({
                request.predicate = NSPredicate(format: filter)
            }, catch: { exception in
                errorMessage = exception.description
            })
        }

        if let errorMessage = errorMessage {
            result.overallResult = .failure
            result.errorMessage = errorMessage
            return (result, [])
        }
        
        let context = self.persistentContainer.newBackgroundContext()
        var coreDataPersons: [CDPerson]?
        
        ObjC.try({
            do {
                coreDataPersons = try context.fetch(request) as? [CDPerson]
            } catch {
                result.errorMessage = error.localizedDescription
                result.overallResult = .failure
            }
        }, catch: { exception in
            errorMessage = exception.description
        })

        if let errorMessage = errorMessage {
            result.overallResult = .failure
            result.errorMessage = errorMessage
            return (result, [])
        }
        
        if let coreDataPersons = coreDataPersons {
            for coreDataPerson in coreDataPersons {
                persons.append(coreDataPerson.convertToPerson())
            }
        }
        
        return (result, persons)
    }

    func clearAll() -> DataStorageOperationResult {
        let result = DataStorageOperationResult()

        for entity in [ "CDPerson", "CDOperationResult" ] {
            do {
                try self.clear(entity)
            } catch {
                result.overallResult = .failure
                result.errorMessage = error.localizedDescription
            }
        }
        return result
    }

    func storeOperationResult(_ result: DataStorageOperationResult) {
        let context = self.persistentContainer.newBackgroundContext()
        
        if let cdOperationResult = NSEntityDescription.insertNewObject(forEntityName: "CDOperationResult",
                                                                       into: context) as? CDOperationResult {
            cdOperationResult.copyPropertiesFrom(result)
        }

        try? context.save()
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
        var retval = [URL]()
        for store in persistentContainer.persistentStoreCoordinator.persistentStores {
            if let url = store.url {
                retval.append(url)
            }
        }
        return retval
    }

    func getNumberOfOperations(withType type: DatabaseOperationType) -> Int {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDOperationResult")
        request.predicate = NSPredicate(format: "operationType = \(type.rawValue)")
        request.resultType = .countResultType
        let count = try? self.persistentContainer.viewContext.count(for: request)
        return Int(count ?? 0)
    }

    func getAverageDurationOfOperation(withType type: DatabaseOperationType) -> Double {
        let request = NSFetchRequest<NSFetchRequestResult>(entityName: "CDOperationResult")
        request.predicate = NSPredicate(format: "operationType = \(type.rawValue)")
        request.resultType = .dictionaryResultType
        
        let keyPathExpression = NSExpression(forKeyPath: "duration")
        let avgExpression = NSExpression(forFunction: "average:", arguments: [ keyPathExpression ])
        let expressionDescription = NSExpressionDescription()
        expressionDescription.name = "averageDuration"
        expressionDescription.expression = avgExpression
        expressionDescription.expressionResultType = .doubleAttributeType
        
        request.propertiesToFetch  = [ expressionDescription ]
        
        let context = self.persistentContainer.newBackgroundContext()
        var averageDuration = 0.0
        do {
            if let objects = try context.fetch(request) as? [Dictionary<String, Any>] {
                averageDuration = objects.first?["averageDuration"] as? Double ?? 0.0
            }
        } catch {
            print("request failed")
        }

        return averageDuration
    }
    
    // MARK: Other
    
    func changeIndexedState(_ newState: Bool) -> DataStorageOperationResult {
        return DataStorageOperationResult()
    }

    // MARK: Private

    func clear(_ table: String) throws {
        let request = NSBatchDeleteRequest(fetchRequest: NSFetchRequest<NSFetchRequestResult>(entityName: table))
        let context = self.persistentContainer.newBackgroundContext()
        let _ = try context.execute(request)
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "StorageTest")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
}
