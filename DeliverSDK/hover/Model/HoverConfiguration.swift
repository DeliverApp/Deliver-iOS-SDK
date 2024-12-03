//
//  HoverConfiguration.swift
//  Hover
//
//  Created by Pedro Carrasco on 14/07/2019.
//  Copyright © 2019 Pedro Carrasco. All rights reserved.
//

import UIKit

// MARK: - HoverConfiguration
internal struct HoverConfiguration {
    
    // MARK: Constant
    private enum Constant {
        static let itemSizeRatio: CGFloat = 0.75
        static let defaultSize: CGFloat = 60.0
    }
    
    // MARK: Properties
    /// Color / Gradient of the floating button
    internal var color: HoverColor
    /// Image displayed in the floating button
    internal var image: UIImage?
    /// Define the animation of the HoverButton's image when expding items
    internal var imageExpandAnimation: ImageExpandAnimation
    /// Size of the floating button
    internal var size: CGFloat
    /// Dictates the size of the image shown in any button (imageSize = size * imageSizeRatio)
    internal var imageSizeRatio: CGFloat
    /// Spacing between the floating button to the edges
    internal var padding: UIEdgeInsets
    /// Font used in items' labels
    internal var font: UIFont?
    /// Color of the overlay
    internal var dimColor: UIColor
    /// Initial position of the floating button
    internal var initialPosition: HoverPosition
    /// Allowed positions in which the floating button can be placed
    internal var allowedPositions: Set<HoverPosition>
    
    var itemConfiguration: HoverItemConfiguration {
        return HoverItemConfiguration(size: size * Constant.itemSizeRatio,
                                      imageSizeRatio: imageSizeRatio,
                                      margin: size * ((1 - Constant.itemSizeRatio) / 2),
                                      font: font,
                                      initialXOrientation: initialPosition.xOrientation)
    }
    
    // MARK: Init
    internal init(image: UIImage? = nil,
                imageExpandAnimation: ImageExpandAnimation = .none,
                color: HoverColor = .color(.blue),
                size: CGFloat = 60.0,
                imageSizeRatio: CGFloat = 0.4,
                padding: UIEdgeInsets = .init(top: 12, left: 12, bottom: 12, right: 12),
                font: UIFont? = nil,
                dimColor: UIColor = UIColor.black.withAlphaComponent(0.75),
                initialPosition: HoverPosition = .bottomRight,
                allowedPositions: Set<HoverPosition> = .all) {
        
        self.color = color
        self.image = image
        self.imageExpandAnimation = imageExpandAnimation
        self.size = size
        self.imageSizeRatio = imageSizeRatio
        self.padding = padding
        self.font = font
        self.dimColor = dimColor
        self.initialPosition = initialPosition
        self.allowedPositions = allowedPositions
    }
}

// MARK: - HoverItemConfiguration
struct HoverItemConfiguration {
    
    let size: CGFloat
    let imageSizeRatio: CGFloat
    let margin: CGFloat
    let font: UIFont?
    let initialXOrientation: Orientation.X
}

// MARK: - ImageExpandAnimation
internal enum ImageExpandAnimation {
    /// No animation
    case none

    /// Rotate considering the radian value. It considers the X and Y orientation when animating.
    case rotate(_ radian: CGFloat)
}
