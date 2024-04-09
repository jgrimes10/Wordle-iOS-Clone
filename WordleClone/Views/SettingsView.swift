//
//  SettingsView.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/9/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var csManager: ColorSchemeManager
    @EnvironmentObject var dm: WordleDataModel
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            VStack {
                Toggle("Hard Mode", isOn: $dm.hardMode)
                Text("Change Theme")
                Picker("Display Mode", selection: $csManager.colorScheme) {
                    Text("Dark").tag(ColorScheme.dark)
                    Text("Light").tag(ColorScheme.light)
                    Text("System").tag(ColorScheme.unspecified)
                }
                .pickerStyle(.segmented)
                
                Spacer()
            }
            .padding()
            .navigationTitle("Options")
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
    SettingsView()
        .environmentObject(ColorSchemeManager())
        .environmentObject(WordleDataModel())
}
