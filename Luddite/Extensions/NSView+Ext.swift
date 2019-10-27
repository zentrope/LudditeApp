//
//  NSView+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension NSView {

    func fill(subview: NSView) {
        fill(subview: subview, withMargins: 0)
    }

    func fill(subview: NSView, withMargins margin: CGFloat) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
        ])
    }

    func center(subview: NSView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func horizontal(subview: NSView, leading: CGFloat = 0, trailing: CGFloat = 0) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
    }

    func top(subview: NSView) {
        top(subview: subview, withMargins: 0)
    }

    func top(subview: NSView, withMargins margin: CGFloat) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
        ])
    }

    func above(bottom: NSView, subview: NSView, top: CGFloat = 0) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: top),
        ])
    }

    func bottom(subview: NSView, withMargins margin: CGFloat = 0) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
        ])
    }

    func between(top: NSView, subview: NSView, bottom: NSView) {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.topAnchor.constraint(equalTo: top.bottomAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
        ])
    }

    func minimum(width: CGFloat, height: CGFloat) {
        heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
    }

    func height(_ value: CGFloat) {
        assert(value > 0)
        heightAnchor.constraint(equalToConstant: value).isActive = true
    }

    func width(min: CGFloat, max: CGFloat = -1) {
        assert(min > 0)
        assert(max == -1 || max >= min)
        widthAnchor.constraint(greaterThanOrEqualToConstant: min).isActive = true
        if max >= min {
            widthAnchor.constraint(lessThanOrEqualToConstant: max).isActive = true
        }
    }

    func borderize() {
        wantsLayer = true
        layer?.borderColor = NSColor.systemRed.cgColor
        layer?.borderWidth = 1
    }
}
