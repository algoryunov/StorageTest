//
//  CDOperationResult+CoreDataClass.swift
//  
//
//  Created by Alexey Goryunov on 10/2/19.
//
//

import Foundation
import CoreData

@objc(CDOperationResult)
public class CDOperationResult: NSManagedObject {
    func copyPropertiesFrom(_ result: DataStorageOperationResult) {
        self.duration = result.duration
        self.message = result.message
        self.operationType = result.operationType.rawValue
        self.result = result.overallResult == .success ? true : false
    }
}
