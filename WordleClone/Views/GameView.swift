//
//  GameView.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/8/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

struct GameView: View {
    @EnvironmentObject var dm: WordleDataModel
    @State private var showSettings: Bool = false
    @State private var showHelp: Bool = false
    
    var body: some View {
        ZStack {
            NavigationStack {
                VStack {
                    if Global.screenHeight < 600 {
                        Text("")
                    }
                    Spacer()
                    VStack(spacing: 3) {
                        ForEach(0...5, id: \.self) { index in
                            GuessView(guess: $dm.guesses[index])
                                .modifier(Shake(animatableData: CGFloat(dm.incorrectAttempts[index])))
                        }
                    }
                    .frame(width: Global.boardWidth, height: 6 * Global.boardWidth / 5)
                    
                    Spacer()
                    KeyboardView()
                        .scaleEffect(Global.keyboardScale)
                        .padding(.top)
                    Spacer()
                }
                .overlay(alignment: .top) {
                    if let toastText = dm.toastText {
                        ToastView(toastText: toastText)
                            .offset(y: 20)
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .topBarLeading) {
                        HStack {
                            if !dm.inPlay {
                                Button {
                                    dm.newGame()
                                } label: {
                                    Text("New")
                                }
                                .foregroundStyle(.secondary)
                            }
                            Button {
                                showHelp.toggle()
                            } label: {
                                Image(systemName: "questionmark.circle")
                            }
                            .foregroundStyle(.secondary)
                        }
                    } //: TOOLBARITEM
                    ToolbarItem(placement: .principal) {
                        Text("WORDLE")
                            .font(.largeTitle)
                            .fontWeight(.heavy)
                            .foregroundStyle(dm.hardMode ? Color(.systemRed) : .primary)
                            .minimumScaleFactor(0.5)
                    } //: TOOLBARITEM
                    ToolbarItem(placement: .topBarTrailing) {
                        HStack {
                            Button {
                                dm.currentStat = Statistic.loadStat()
                                dm.showStats.toggle()
                            } label: {
                                Image(systemName: "chart.bar")
                            }
                            .foregroundStyle(.secondary)
                            
                            Button {
                                showSettings.toggle()
                            } label: {
                                Image(systemName: "gearshape.fill")
                            }
                            .foregroundStyle(.secondary)
                        }
                    }
                }
                .sheet(isPresented: $showSettings, content: {
                    SettingsView()
                })
            } //: NAVIGATIONSTACK
            if dm.showStats {
                StatsView()
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showHelp, content: {
            HelpView()
        })
    }
}

#Preview {
    GameView()
        .environmentObject(WordleDataModel())
}
