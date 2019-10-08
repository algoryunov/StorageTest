//
//  CDPerson+CoreDataClass.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/26/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//
//

import Foundation
import CoreData


public class CDPerson: NSManagedObject {
    
    func convertToPerson() -> Person {
        let person = Person()
        person.id = self.id
        person.firstName = self.firstName ?? ""
        person.lastName = self.lastName ?? ""
        person.birthDateTime = self.birthDateTime 
        return person
    }

}
