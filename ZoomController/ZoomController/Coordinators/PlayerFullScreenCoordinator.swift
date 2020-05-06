////
////  PlayerFullScreenCoordinator.swift
////  ZoomController
////
////  Created by Maxim Komlev on 5/5/20.
////  Copyright © 2020 Maxim Komlev. All rights reserved.
////
//
//import UIKit
//import Foundation
//
//protocol PlayerFullScreenControllerCoordinatorProtocol: class {
//    init(playerViewController: PlayerViewControllerProtocol)
//    
//    func presentInWidget(viewController: PlayerViewControllerTransitioningProtocol)
//    func presentInFullScreen(viewController: PlayerViewControllerTransitioningProtocol)
//}
//
//protocol PlayerFullScreenCoordinatorDelegate: class {
//}
//
//class PlayerFullScreenCoordinator: PlayerFullScreenControllerCoordinatorProtocol {
//
//    // MARK: Fields
//    
//    private var playerViewController: PlayerViewControllerProtocol!
//    
//    // MARK: Initializers/Deinitializer
//    
//    init(playerViewController: PlayerViewControllerProtocol) {
//        <#statements#>
//    }
//
//    // MARK: Methods
//    
//    func start() {}
//    
//    func present(_ controller: PlayerFullScreenCoordinatorDelegate) {
//        // Install Handler
//        coordinator.didFinish = { [weak self] (coordinator) in
//            self?.popCoordinator(coordinator)
//        }
//        
//        // Start Coordinator
//        coordinator.start()
//        
//        // Append to Child Coordinators
//        childCoordinators.append(coordinator)
//    }
//    
//    func dismiss(_ controller: PlayerFullScreenCoordinatorDelegate) {
//        // Remove Coordinator From Child Coordinators
//        if let index = childCoordinators.firstIndex(where: { $0 === coordinator }) {
//            childCoordinators.remove(at: index)
//        }
//    }
//
//}
