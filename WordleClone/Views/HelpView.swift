//
//  HelpView.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/9/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct HelpView: View {
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading) {
                Text(
"""
Guess the **WORDLE** in 6 tries.

Each guess must be a valid 5 letter word. Hit the enter button to submit.

After each guess, the color of the tiles will change to show how close your guess was to the word.
"""
                )
                Divider()
                    .padding(.vertical)
                Text("**Examples**")
                    .padding(.bottom)
                Image("Weary")
                    .resizable()
                    .scaledToFit()
                Text("The letter **W** is in the word and in the correct spot.")
                    .padding(.bottom)
                
                Image("Pills")
                    .resizable()
                    .scaledToFit()
                Text("The letter **I** is in the word but in the wrong spot.")
                    .padding(.bottom)
                
                Image("Vague")
                    .resizable()
                    .scaledToFit()
                Text("The letter **U** is not in the word in any spot.")
                
                Divider()
                    .padding(.vertical)
                
                Text("A new WORDLE will be available each day!")
                    .fontWeight(.bold)
            }
            .frame(width: min(Global.screenWidth - 40, 350))
            .navigationTitle("HOW TO PLAY")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("**X**")
                    }
                    .foregroundStyle(.secondary)
                }
            }
        }
    }
}

#Preview {
    HelpView()
}
