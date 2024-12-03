//
//  ClosureTapGestureRecognizer.swift
//  DeliverSDK
//
//  Created by Benjamin FROLICHER on 18/12/2023.
//

import UIKit

/// A custom subclass of `UITapGestureRecognizer` that allows attaching a closure-based action
/// to the tap gesture, removing the need for a selector or external target-action methods.
/// This class encapsulates the action to be executed when a tap gesture is recognized.
internal final class ClosureTapGestureRecognizer: UITapGestureRecognizer {
    
    /// A closure to be executed when the tap gesture is recognized.
    private let action: () -> Void
    
    /// Initializes the gesture recognizer with a closure that is triggered when the tap gesture is detected.
    ///
    /// - Parameter action: A closure that will be executed when the gesture is recognized.
    /// - Note: The closure is marked as `@escaping` since it is stored and called asynchronously.
    ///
    /// Example usage:
    /// ```swift
    /// let tapGesture = ClosureTapGestureRecognizer {
    ///     print("Tapped!")
    /// }
    /// view.addGestureRecognizer(tapGesture)
    /// ```
    init(action: @escaping () -> Void) {
        self.action = action
        super.init(target: nil, action: nil)
        self.addTarget(self, action: #selector(execute))
    }
    
    /// This method is triggered when the gesture is recognized.
    /// It calls the closure stored in the `action` property to execute the user-defined behavior.
    ///
    /// - Note: This method is private and only used internally when the tap gesture is recognized.
    @objc private func execute() {
        action()
    }
}
