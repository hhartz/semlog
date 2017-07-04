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

    init(with log: String) {
        let change = log.components(separatedBy: ":")
        if change.count != 2 {
            category = "Other"
            message = log
        } else {
            category = change[0].trimmed.lowercased().capitalized
            message = change[1].trimmed
        }
    }
}

class SemanticLog {
    var output: String
    var categories = NSDictionary()

    init(with changelist: String) {
        categories = buildCategories(from: changelist)
        output = categories.toString()
    }

    func buildCategories(from changes: String) -> NSDictionary {
        let lines = changes.components(separatedBy: "\n")
        let categories = NSMutableDictionary()
        for line in lines {
            let change = Change.init(with: line)
            var categoryList = categories.value(forKey: change.category) as? [String] ?? [String]()
            categoryList.append(change.message)
            categories.setValue(categoryList, forKey: change.category)
        }
        return categories
    }
}
