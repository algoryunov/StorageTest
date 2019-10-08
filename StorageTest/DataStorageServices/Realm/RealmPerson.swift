//
//  RealmPerson.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/27/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import RealmSwift

class RealmPerson: Object {
    @objc dynamic var id:            Int32  = 0
    @objc dynamic var firstName:     String = ""
    @objc dynamic var lastName:      String = ""
    @objc dynamic var birthDateTime: Double = 0.0
    
    
    class func create(fromPerson person: Person) -> RealmPerson {
        let realmPerson = RealmPerson()
        realmPerson.id = person.id
        realmPerson.firstName = person.firstName
        realmPerson.lastName = person.lastName
        realmPerson.birthDateTime = person.birthDateTime
        return realmPerson
    }
    
    func convertToPerson() -> Person {
        let person = Person()
        person.id = self.id
        person.firstName = self.firstName
        person.lastName = self.lastName
        person.birthDateTime = self.birthDateTime
        return person
    }
}
