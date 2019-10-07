//
//  CommonExtensions.swift
//  StorageTest
//
//  Created by Alexey Goryunov on 10/7/19.
//  Copyright © 2019 Alexey Goryunov. All rights reserved.
//

import Foundation

enum StringAlignmentType {
    case Left, Center, Right
}

extension String {
    func align(_ type: StringAlignmentType, _ width: Int) -> String {
        let maxTextWidth = width - 2
        var output = self
        if output.count > maxTextWidth {
            let index = output.index(output.startIndex, offsetBy: maxTextWidth)
            output.removeSubrange(output.startIndex..<index)
        }
        
        var leftSpaces = ""
        var rightSpaces = ""
        
        if type == .Left {
            leftSpaces  = " "
            rightSpaces = String(repeating: " ", count: (width - output.count - 1))
        } else if type == .Center {
            let totalSpacesCount = width - output.count
            leftSpaces  = String(repeating: " ", count: totalSpacesCount / 2)
            rightSpaces = String(repeating: " ", count: totalSpacesCount - leftSpaces.count)
        } else if type == .Right {
            leftSpaces  = String(repeating: " ", count: (width - output.count - 1))
            rightSpaces = " "
        }
        
        return "\(leftSpaces)\(output)\(rightSpaces)"
    }
}

extension Double {
    func format(f: String) -> String {
        return String(format: "%\(f)f", self)
    }
}
