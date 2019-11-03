//
//  EmptyVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/26/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

class EmptyVC: NSViewController {

    override func loadView() {

        let label = NSTextField(labelWithString: "No Post Selected")
            .font(NSFont.systemFont(ofSize: 22, weight: .regular))
            .textColor(.secondaryLabelColor)

        self.view = NSView(frame: .zero)
            .center(subview: label)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
}
