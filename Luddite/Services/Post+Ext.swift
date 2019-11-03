//
//  Post+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 11/2/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation

extension Post {

    var month: Date? {
        guard let date = dateCreated else { return nil }
        let dc = Calendar.current.dateComponents([.year, .month], from: date)
        return Calendar.current.date(from: dc)
    }
}
