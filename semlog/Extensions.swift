//
//  Extensions.swift
//  semlog
//
//  Created by Henrik Hartz on 04/07/2017.
//  Copyright © 2017 Henrik Hartz. All rights reserved.
//

import Foundation

extension NSDictionary {
    func toString() -> String {
        var result = ""
        for category in allKeys {
            result += "\(category):\n"
            if let descriptions = self[category] as? [String] {
                for description in descriptions {
                    result += "  - \(description)\n"
                }
            }
            result += "\n"
        }
        return result
    }
}

extension String {
    var trimmed: String {
        return self.trimmingCharacters(in: NSCharacterSet.whitespacesAndNewlines)
    }
}
