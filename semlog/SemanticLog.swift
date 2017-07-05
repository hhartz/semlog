//
//  SemanticLog.swift
//  semlog
//
//  Created by Henrik Hartz on 04/07/2017.
//  Copyright © 2017 Henrik Hartz. All rights reserved.
//

import Foundation

class Change {
    var category: String
    var message: String

    init?(with log: String) {
        if log.trimmed.characters.count == 0 {
            return nil
        }

        if let indexOfColon = log.characters.index(of: ":") {
            category = String(log.characters.prefix(upTo: indexOfColon)).trimmed.capitalized
            let indexAfterColon = log.index(indexOfColon, offsetBy: 1)
            // ignore author
            if indexAfterColon == log.endIndex {
                return nil
            }
            message = String(log.characters.suffix(from: indexAfterColon)).trimmed
        } else {
            category = "Other"
            message = log.trimmed
        }
    }
}

class SemanticLog {
    var output: String = ""
    var categories = NSDictionary()

    init(with changelist: String) {
        categories = buildCategories(from: changelist.trimmed)
        output = categories.toString()
    }

    func buildCategories(from changes: String) -> NSDictionary {
        let lines = changes.components(separatedBy: "\n")
        let categories = NSMutableDictionary()
        for line in lines {
            if let change = Change.init(with: line) {
                var categoryList = categories.value(forKey: change.category) as? [String] ?? [String]()
                categoryList.append(change.message)
                categories.setValue(categoryList, forKey: change.category)
            }
        }
        return categories
    }
}
