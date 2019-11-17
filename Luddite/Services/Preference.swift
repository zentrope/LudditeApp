//
//  Preference.swift
//  Luddite
//
//  Created by Keith Irwin on 11/16/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Foundation

enum Preferences {
    @Preference("use.titles.on.index", default: false) static var isIndexTitled
    @Preference("use.titles.on.pages", default: false) static var isPagesTitled
}

@propertyWrapper
struct Preference<T> {

    let key: String
    var defaultValue: T

    init(_ key: String, default value: T) {
        self.key = key
        self.defaultValue = value
    }

    var wrappedValue: T {
        get {
            UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)

        }
    }
}
