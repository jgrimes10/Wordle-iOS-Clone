//
//  ToastView.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/8/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct ToastView: View {
    let toastText: String
    
    var body: some View {
        Text(toastText)
            .foregroundStyle(Color(.systemBackground))
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(.primary))
    }
}

#Preview {
    ToastView(toastText: "Not in the word list")
}
