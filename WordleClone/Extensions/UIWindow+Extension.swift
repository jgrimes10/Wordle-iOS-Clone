//
//  UIWindow+Extension.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/9/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import UIKit

extension UIWindow {
    static var key: UIWindow? {
        guard let scene = UIApplication.shared.connectedScenes.first,
              let windowSceneDelegate = scene.delegate as? UIWindowSceneDelegate,
              let window = windowSceneDelegate.window else {
            return nil
        }
        return window
    }
}
