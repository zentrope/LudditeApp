//
//  NSView+Ext.swift
//  Luddite
//
//  Created by Keith Irwin on 10/17/19.
//  Copyright © 2019 Zentrope. All rights reserved.
//

import Cocoa

extension NSView {

    @discardableResult
    func fill(subview: NSView, withMargins margin: CGFloat = 0) -> Self {
        return fill(subview: subview, top: margin, leading: margin, bottom: -margin, trailing: -margin)
    }

    @discardableResult
    func fill(subview: NSView, top: CGFloat = 0, leading: CGFloat = 0, bottom: CGFloat = 0, trailing: CGFloat = 0) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: top),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: bottom),
        ])
        return self
    }

    @discardableResult
    func center(subview: NSView)  -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.centerXAnchor.constraint(equalTo: centerXAnchor),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    @discardableResult
    func horizontal(subview: NSView, leading: CGFloat = 0, trailing: CGFloat = 0)  -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: trailing),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: leading),
            subview.centerYAnchor.constraint(equalTo: centerYAnchor)
        ])
        return self
    }

    @discardableResult
    func top(subview: NSView, withMargins margin: CGFloat = 0)  -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.topAnchor.constraint(equalTo: topAnchor, constant: margin),
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
        ])
        return self
    }

    @discardableResult
    func above(bottom: NSView, subview: NSView, top: CGFloat = 0) -> Self  {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
            subview.topAnchor.constraint(equalTo: topAnchor, constant: top),
        ])
        return self
    }

    @discardableResult
    func below(top: NSView, subview: NSView) -> Self {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor),
            subview.topAnchor.constraint(equalTo: top.bottomAnchor),
        ])
        return self
    }

    @discardableResult
    func bottom(subview: NSView, withMargins margin: CGFloat = 0) -> Self  {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor, constant: margin),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -margin),
            subview.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -margin),
        ])
        return self
    }

    @discardableResult
    func between(top: NSView, subview: NSView, bottom: NSView) -> Self  {
        addSubview(subview)
        subview.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            subview.leadingAnchor.constraint(equalTo: leadingAnchor),
            subview.trailingAnchor.constraint(equalTo: trailingAnchor),
            subview.topAnchor.constraint(equalTo: top.bottomAnchor),
            subview.bottomAnchor.constraint(equalTo: bottom.topAnchor),
        ])
        return self
    }

    @discardableResult
    func minimum(width: CGFloat, height: CGFloat) -> Self  {
        heightAnchor.constraint(greaterThanOrEqualToConstant: height).isActive = true
        widthAnchor.constraint(greaterThanOrEqualToConstant: width).isActive = true
        return self
    }

    @discardableResult
    func height(_ value: CGFloat) -> Self  {
        assert(value > 0)
        heightAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }

    @discardableResult
    func width(_ value: CGFloat) -> Self  {
        assert(value > 0)
        widthAnchor.constraint(equalToConstant: value).isActive = true
        return self
    }

    @discardableResult
    func width(min: CGFloat, max: CGFloat = -1) -> Self  {
        assert(min > 0)
        assert(max == -1 || max >= min)
        widthAnchor.constraint(greaterThanOrEqualToConstant: min).isActive = true
        if max >= min {
            widthAnchor.constraint(lessThanOrEqualToConstant: max).isActive = true
        }
        return self
    }

    @discardableResult
    func borderize(_ color: NSColor = .systemRed) -> Self {
        wantsLayer = true
        layer?.borderColor = color.cgColor
        layer?.borderWidth = 0.5
        return self
    }
}
