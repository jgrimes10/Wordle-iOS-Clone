//
//  LetterButtonView.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/8/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct LetterButtonView: View {
    @EnvironmentObject var dm: WordleDataModel
    var letter: String
    
    var body: some View {
        Button {
            dm.addToCurrentWord(letter)
        } label: {
            Text(letter)
                .font(.system(size: 20))
                .frame(width: 35, height: 50)
                .background(dm.keyColors[letter])
                .foregroundStyle(.foreground)
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    LetterButtonView(letter: "L")
        .environmentObject(WordleDataModel())
}
