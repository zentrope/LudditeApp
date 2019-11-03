//
//  Date+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 11/2/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation

extension Date {
    func formatted(pattern: String) -> String {
        let f = DateFormatter()
        f.dateFormat = pattern
        return f.string(from: self)
    }
}
