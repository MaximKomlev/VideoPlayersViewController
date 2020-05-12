//
//  PlayerFullScreenTransitioningWindow.swift
//  ZoomController
//
//  Created by Maxim Komlev on 5/11/20.
//  Copyright © 2020 Maxim Komlev. All rights reserved.
//

import UIKit
import Foundation

class PlayerFullScreenTransitioningWindow: UIWindow {
    
    override init(windowScene: UIWindowScene) {
        super.init(windowScene: windowScene)
        
        rootViewController = PlayerFullScreenTransitioningWindowRootController()
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)

        rootViewController = PlayerFullScreenTransitioningWindowRootController()
        backgroundColor = .clear
    }
    
}

class PlayerFullScreenTransitioningWindowRootController: UIViewController {
    
      // MARK: Fields
    
      private unowned var playerViewController: PlayerViewControllerProtocol?
      private var originalBackGroundColor: UIColor? = .clear
      
      // MARK: Initializer/Deinitializer
      
      required convenience init() {
          self.init(nibName: nil, bundle: nil)
      }

      override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
          super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
      }

      required init?(coder: NSCoder) {
          super.init(coder: coder)
      }
      
      // MARK: Controller life cycle

      override func viewDidLoad() {
          super.viewDidLoad()

          view.isUserInteractionEnabled = true
          view.backgroundColor = .clear
      }

      override func viewDidLayoutSubviews() {
          super.viewDidLayoutSubviews()
      }
          
      override var prefersStatusBarHidden: Bool {
          return true
      }
      
      override var preferredScreenEdgesDeferringSystemGestures: UIRectEdge {
          return .top
      }
      
      override var prefersHomeIndicatorAutoHidden: Bool {
          return true
      }

      override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
          return .all
      }

      override var shouldAutorotate: Bool {
          return true
      }
              
}
