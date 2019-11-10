//
//  NSWindow+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 11/9/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension NSWindow {

    func confirm(title: String, info: String, yes: String, no: String, style: NSAlert.Style? = .critical, _ completion: @escaping (Bool) -> Void) {
        let alert = NSAlert()
        alert.messageText = title
        alert.informativeText = info
        alert.addButton(withTitle: yes)
        alert.addButton(withTitle: no)
        alert.alertStyle = .critical

        alert.beginSheetModal(for: self) { response in
            if response == .alertFirstButtonReturn {
                completion(true)
            } else {
                completion(false)
            }
        }
    }

    func alert(message: String, info: String? = nil, _ completion: (() -> Void)? = nil) {
        DispatchQueue.main.async {
            let alert = NSAlert()
            alert.alertStyle = .critical
            alert.messageText = message

            let limit = 512
            if let x = info {
                alert.informativeText = x.count > limit ? String(x[..<x.index(x.startIndex, offsetBy: limit)]) : x
            }

            alert.beginSheetModal(for: self) { x in
                completion?()
            }
        }
    }
}
