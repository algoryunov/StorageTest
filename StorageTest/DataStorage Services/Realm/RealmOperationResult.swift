//
//  RealmOperationResult.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 10/7/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import UIKit

import RealmSwift

class RealmOperationResult: Object {
    @objc dynamic var duration = 0.0
    @objc dynamic var message = ""
    @objc dynamic var overallResult = false
    @objc dynamic var operationType = Int16(0)
    
    
    class func create(fromOperationResult result: DataStorageOperationResult) -> RealmOperationResult {
        let realmOperationResult = RealmOperationResult()
        realmOperationResult.duration = result.duration
        realmOperationResult.message = result.message
        realmOperationResult.overallResult = result.overallResult == .success ? true : false
        realmOperationResult.operationType = result.operationType.rawValue
        return realmOperationResult
    }
    
    func convertToOperationResult() -> DataStorageOperationResult {
        let result = DataStorageOperationResult()
        result.duration = self.duration
        result.message = self.message
        result.overallResult = self.overallResult ? .success : .failure
        result.operationType = DatabaseOperationType(rawValue: self.operationType) ?? .read
        return result
    }
}
