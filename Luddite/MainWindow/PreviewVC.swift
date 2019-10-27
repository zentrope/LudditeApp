//
//  PreviewVC.swift
//  Luddite
//
//  Created by Keith Irwin on 10/27/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa
import WebKit
import os.log

fileprivate let logger = OSLog(subsystem: Bundle.main.bundleIdentifier!, category: "PreviewVC")

class PreviewVC: NSViewController {

    private lazy var webView = WKWebView()

    override func loadView() {
        webView.navigationDelegate = self
        self.view = NSView(frame: .zero)
            .fill(subview: webView)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    func load(_ html: String?) {
        guard let resourceDir = Bundle.main.resourcePath else { return }
        let dir = URL(fileURLWithPath: resourceDir, isDirectory: true)
        let doc = wrap(html ?? "<h1>Nothing to show</h1>")
        webView.loadHTMLString(doc, baseURL: dir)
    }

    private func wrap(_ body: String) -> String {
        return """
          <!doctype html>
          <html>
            <head>
              <link rel="stylesheet" href="style.css" type="text/css"/>
            </head>
            <body>
              <main>
              \(body)
              </main>
            </body>
          </html>
        """
    }
}

extension PreviewVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        // Only allow the user to open links in their default browser, rather than
        // within the webview itself.
        if let url = navigationAction.request.url {
            if url.absoluteString.hasPrefix("http") {
                NSWorkspace.shared.open(url)
                decisionHandler(WKNavigationActionPolicy.cancel)
                return
            }
        }
        decisionHandler(WKNavigationActionPolicy.allow)
    }

}
