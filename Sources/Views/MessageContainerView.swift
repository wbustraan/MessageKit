/*
 MIT License

 Copyright (c) 2017-2018 MessageKit

 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:

 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.

 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import AppKit

open class MessageContainerView: NSImageView {

    // MARK: - Properties

    private let imageMask = CALayer()

    open var style: MessageStyle = .none {
        didSet {
            applyMessageStyle()
        }
    }

    open override var frame: CGRect {
        didSet {
            sizeMaskToView()
        }
    }

    // MARK: - Methods

    private func sizeMaskToView() {
        switch style {
        case .none, .custom:
            break
        case .bubble, .bubbleTail:
            imageMask.frame = bounds
        case .bubbleOutline, .bubbleTailOutline:
            imageMask.frame = bounds.insetBy(dx: 1.0, dy: 1.0)
        }
    }

    private func applyMessageStyle() {
        wantsLayer = true
        
        switch style {
        case .bubble, .bubbleTail:
            imageMask.contents = style.image
            sizeMaskToView()
            layer?.mask = imageMask
            image = nil
        case .bubbleOutline(let color):
            let bubbleStyle: MessageStyle = .bubble
            imageMask.contents = bubbleStyle.image
            sizeMaskToView()
            layer?.mask = imageMask
            image = style.image
            // TODO: - Do we need to tint in Cocoa?
//            tintColor = color
        case .bubbleTailOutline(let color, let tail, let corner):
            let bubbleStyle: MessageStyle = .bubbleTailOutline(.white, tail, corner)
            imageMask.contents = bubbleStyle.image
            sizeMaskToView()
            layer?.mask = imageMask
            image = style.image
//            tintColor = color
        case .none:
            layer?.mask = nil
            image = nil
//            tintColor = nil
        case .custom(let configurationClosure):
            layer?.mask = nil
            image = nil
//            tintColor = nil
            configurationClosure(self)
        }
    }
}
