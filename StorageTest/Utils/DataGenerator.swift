//
//  DataGenerator.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 9/23/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import UIKit

class DataGenerator: NSObject {
    
    // MARK: Public

    class func generatePersons(_ startIndex: Int, _ count: Int = 100000) -> [Person] {
        let firstNames = self.readFirstNames()
        let lastNames = self.readLastNames()
        let currentTimestamp = Date.init().timeIntervalSince1970
        var retval = [Person]()

        for i in 0..<count {
            let person = Person()
            person.id = Int32(startIndex + i)
            person.firstName = firstNames.randomElement()!
            person.lastName  = lastNames.randomElement()!
            person.birthDateTime = Double.random(in: 0..<currentTimestamp)
            retval.append(person)
        }

        return retval
    }
    
    class func generateCompanies() -> [Company] {
        let retval = [Company]()
        return retval
    }

    // MARK: Private Utils

    private class func readFirstNames() -> [String] {
        return self.readStrings(from: "first-names")
    }

    private class func readLastNames() -> [String] {
        return self.readStrings(from: "last-names")
    }
    
    private class func readStrings(from filename: String) -> [String] {
        guard let path = Bundle.main.url(forResource: filename, withExtension: "json"),
            let data = try? Data(contentsOf: path),
            let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []),
            let jsonArray = jsonObject as? [String]
            else { return [] }
        
        return jsonArray
    }
}
