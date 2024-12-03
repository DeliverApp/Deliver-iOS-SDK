//
//  Coordinator.swift
//  Deliver
//
//  Created by Benjamin FROLICHER on 28/12/2023.
//

import UIKit

internal protocol CoordinatorType {
    
    associatedtype ReturnType
    
    /// Unique coordinator identifier
    var identifier: UUID { get }
    
    /// Used that launch coordinator
    func start()
    
    /// Used used to keep a reference to a child coordinator
    func store(_ coordinator: any CoordinatorType)
    
    /// Used used to start a child coordinator
    func coordinate(_ coordinator: any CoordinatorType)
    
    /// Used to release a child coordinator
    func free(_ coordinator: any CoordinatorType)
    
    /// Called when a coordinator finish its task
    func onFinish(_ finish: @escaping (_ coordinator: any CoordinatorType, _ returns: ReturnType) -> Void) -> Self
}

internal class Coordinator<ReturnType>: NSObject, CoordinatorType {
    
    var finish: ((_ coordinator: any CoordinatorType, _ returns: ReturnType) -> Void)?
    
    var identifier = UUID()

    /// List of child coordinator
    private var childCoordinators = [UUID: any CoordinatorType]()
    
    open func store(_ coordinator: any CoordinatorType) {
        self.childCoordinators[coordinator.identifier] = coordinator
    }
    
    open func free(_ coordinator: any CoordinatorType) {
        self.childCoordinators[coordinator.identifier] = nil
    }
    
    open func coordinate(_ coordinator: any CoordinatorType) {
        self.store(coordinator)
        coordinator.start()
    }
    
    func start() {
        fatalError("Start method must be implemented.")
    }
    
    @discardableResult
    func onFinish(_ finish: @escaping (_ coordinator: any CoordinatorType, _ returns: ReturnType) -> Void) -> Self {
        self.finish = finish
        return self
    }
}
