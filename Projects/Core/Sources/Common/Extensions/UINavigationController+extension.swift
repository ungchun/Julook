//
//  UINavigationController+extension.swift
//  Core
//
//  Created by Kim SungHun on 3/9/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import UIKit

extension UINavigationController: @retroactive ObservableObject, @retroactive UIGestureRecognizerDelegate {
  override open func viewDidLoad() {
    super.viewDidLoad()
    interactivePopGestureRecognizer?.delegate = self
  }
  
  open func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
    return viewControllers.count > 1
  }
}
