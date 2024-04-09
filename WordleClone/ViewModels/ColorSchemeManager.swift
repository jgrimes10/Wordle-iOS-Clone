//
//  ColorSchemeManager.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/9/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

enum ColorScheme: Int {
    case unspecified, light, dark
}


class ColorSchemeManager: ObservableObject {
    @AppStorage("colorScheme") var colorScheme: ColorScheme = .unspecified {
        didSet {
            applyColorScheme()
        }
    }
    
    func applyColorScheme() {
        UIWindow.key?.overrideUserInterfaceStyle = UIUserInterfaceStyle(rawValue: colorScheme.rawValue)!
    }
}
