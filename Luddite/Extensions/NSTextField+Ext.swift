//
//  NSTextField+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 10/26/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension NSTextField {

    func font(_ font: NSFont) -> Self {
        self.font = font
        return self
    }

    func textColor(_ color: NSColor) -> Self {
        self.textColor = color
        return self
    }
}
