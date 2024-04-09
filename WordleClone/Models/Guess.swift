//
//  Guess.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/8/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct Guess {
    let index: Int
    var word = "     "
    var bgColors = [Color](repeating: .wrong, count: 5)
    var cardFlipped = [Bool](repeating: false, count: 5)
    var guessLetters: [String] {
        word.map { String($0) }
    }
    
    // 🟨🟩🟩🟩⬛️
    var results: String {
        let tryColors: [Color : String] = [.misplaced : "🟨", .correct : "🟩", .wrong : "⬛️"]
        return bgColors.compactMap { tryColors[$0] }.joined(separator: "")
    }
}
