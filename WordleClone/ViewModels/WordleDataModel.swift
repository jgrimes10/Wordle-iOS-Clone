//
//  WordleDataModel.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/8/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import SwiftUI

// The WordleDataModel class is designed to be the central model for a Wordle game clone.
// It manages the game's state, including guesses, the current word, selected word,
// and the state of the game. It adheres to the ObservableObject protocol to allow
// SwiftUI views to update reactively as the game state changes.
class WordleDataModel: ObservableObject {
    // Published properties allow the SwiftUI view to re-render whenever these values change.
    @Published var guesses: [Guess] = [] // Stores the player's guesses.
    @Published var incorrectAttempts = [Int](repeating: 0, count: 6) // Used to animate the Shake animation.
    @Published var toastText: String? // Stores text to show in toast message.
    @Published var showStats: Bool = false // Used to show or hide the stats screen in the game.
    @AppStorage("hardMode") var hardMode = false
    
    var keyColors = [String : Color]() // Maps each letter to its current color state on the keyboard.
    var matchedLetters = [String]() // Array to track letters that were matched to color the keyboard.
    var misplacedLetters = [String]() // Array to track letters that were misplaced to color the keyboard.
    var correctlyPlacedLetters = [String]()
    var selectedWord = "" // The word the player needs to guess.
    var currentWord = "" // The word currently being input by the player.
    var tryIndex = 0 // The index of the current attempt, starting from 0.
    var inPlay = false // Indicates whether the game is currently in play.
    var gameOver = false // Indicates whether the game is over.
    var toastWords = ["Genius", "Magnificent", "Impressive", "Splendid", "Great", "Phew"]
    var currentStat: Statistic
    
    // Computed property to check if the game has started based on the current word or try index.
    var gameStarted: Bool {
        !currentWord.isEmpty || tryIndex > 0
    }
    
    // Computed property to determine if the keys should be disabled (game not in play or current word has reached max length).
    var disabledKeys: Bool {
        !inPlay || currentWord.count == 5
    }
    
    // Initializes a new game upon creation of the model.
    init() {
        // Initialize the current statistic.
        currentStat = Statistic.loadStat()
        newGame()
    }
    
    // MARK: SETUP
    
    // Starts a new game, selects a random word, and prepares the game state.
    func newGame() {
        populateDefaults() // Reset game state to default values.
        
        // Select a random word from a predefined list as the target word for the game.
        selectedWord = Global.commonWords.randomElement()!
        
        correctlyPlacedLetters = [String](repeating: "-", count: 5)
        
        // Reset the user guess word to an empty string for a new game.
        currentWord = ""
        
        // Set the game to be in play.
        inPlay = true
        
        // Reset try index to 0 for a new game.
        tryIndex = 0
        
        // Set gameover to false.
        gameOver = false
        
        print(selectedWord)
    }
    
    // Resets game state to default values, preparing for a new game or resetting the current game.
    func populateDefaults() {
        // Clear any existing guesses.
        guesses = []
        
        // Initialize guesses with default values.
        for index in 0...5 {
            guesses.append(Guess(index: index))
        }
        
        // Reset keyboard color state for each letter to unused.
        let letters = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for char in letters {
            keyColors[String(char)] = .unused
        }
        
        // Reset tracking arrays for the new game.
        matchedLetters = []
        misplacedLetters = []
    }
    
    // MARK: GAME PLAY
    
    // Adds a letter to the current word and updates the guess.
    func addToCurrentWord(_ letter: String) {
        currentWord += letter
        updateRow()
    }
    
    
    func enterWord() {
        // Checks to see if the player guessed the correct word.
        if currentWord == selectedWord {
            gameOver = true
            print("You win!")
            setCurrentGuessColors()
            currentStat.update(win: true, index: tryIndex)
            showToast(with: toastWords[tryIndex])
            inPlay = false
        } else {
            // Attempts to submit the current word, verifying its validity.
            // If valid, it does something (implementation pending), else it sets the incorrectAttempts to trigger the Shake animation.
            if verifyWord() {
                if hardMode {
                    if let toastString = hardCorrectCheck() {
                        showToast(with: toastString)
                        return
                    }
                    if let toastString = hardMisplacedCheck() {
                        showToast(with: toastString)
                        return
                    }
                }
                setCurrentGuessColors()
                tryIndex += 1
                currentWord = ""
                if tryIndex == 6 {
                    currentStat.update(win: false)
                    gameOver = true
                    inPlay = false
                    showToast(with: selectedWord)
                }
            } else {
                withAnimation {
                    self.incorrectAttempts[tryIndex] += 1
                }
                showToast(with: "Not in word list")
                incorrectAttempts[tryIndex] = 0
            }
        }
    }
    
    // Removes the last letter from the current word and updates the guess.
    func removeLetterFromCurrentWord() {
        currentWord.removeLast()
        updateRow()
    }
    
    // Updates the current guess's word to match the currentWord, padding with spaces if necessary.
    func updateRow() {
        let guessWord = currentWord.padding(toLength: 5, withPad: " ", startingAt: 0)
        guesses[tryIndex].word = guessWord
    }
    
    // Verifies whether the current word exists in the dictionary.
    func verifyWord() -> Bool {
        UIReferenceLibraryViewController.dictionaryHasDefinition(forTerm: currentWord)
    }
    
    func hardCorrectCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for i in 0...4 {
            if correctlyPlacedLetters[i] != "-" {
                if guessLetters[i] != correctlyPlacedLetters[i] {
                    let formatter = NumberFormatter()
                    formatter.numberStyle = .ordinal
                    return "\(formatter.string(for: i + 1)!) letter must be `\(correctlyPlacedLetters[i])`."
                }
            }
        }
        return nil
    }
    
    func hardMisplacedCheck() -> String? {
        let guessLetters = guesses[tryIndex].guessLetters
        for letter in misplacedLetters {
            if !guessLetters.contains(letter) {
                return ("Must contain the letter `\(letter)`.")
            }
        }
        return nil
    }
    
    // Updates the colors of the current guess's letters based on their accuracy in matching the selected word.
    func setCurrentGuessColors() {
        // Convert the selected word into an array of its letters as strings for easier comparison.
        let correctLetters = selectedWord.map { String($0) }
        
        // Create a dictionary to track the frequency of each letter in the selected word.
        var frequency = [String : Int]()
        
        // Populate the frequency dictionary with the count of each letter in the selected word.
        for letter in correctLetters {
            frequency[letter, default: 0] += 1
        }
        
        // First pass: Identity and mark correct letters (correct position and value).
        for index in 0...4 {
            let correctLetter = correctLetters[index] // The correct letter at the current index.
            let guessLetter = guesses[tryIndex].guessLetters[index] // The guessed letter at the current index.
            
            // If the guessed letter matches the correct letter at this index, mark it correct.
            if guessLetter == correctLetter {
                guesses[tryIndex].bgColors[index] = .correct // Update the background color to indicate correct match.
                
                // If the matched letter isn't being tracked yet, add it to the tracking array.
                if !matchedLetters.contains(guessLetter) {
                    matchedLetters.append(guessLetter)
                    
                    // Set the key color.
                    keyColors[guessLetter] = .correct
                }
                // Check if letter is in misplaced, and remove it.
                if misplacedLetters.contains(guessLetter) {
                    if let index = misplacedLetters.firstIndex(where: { $0 == guessLetter }) {
                        misplacedLetters.remove(at: index)
                    }
                }
                correctlyPlacedLetters[index] = correctLetter
                frequency[guessLetter]! -= 1 // Decrement the frequency since this letter is correctly guessed.
            }
        }
        
        // Second pass: Identify and mark misplaced letters (correct value but wrong position).
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index] // The guessed letter at the current index.
            
            // Check if the guessed letter is in the correct word, hasn't been marked as correct, and still has remaining frequency.
            // This ensures that the letter is not overcounted (e.g. guessing 'AAA' for the word 'ALFA').
            if correctLetters.contains(guessLetter) && guesses[tryIndex].bgColors[index] != .correct && frequency[guessLetter]! > 0 {
                guesses[tryIndex].bgColors[index] = .misplaced // Update the background color to indicate misplaced match.
                
                // If the misplaced letter isn't being tracked yet, add it to the tracking array.
                if !misplacedLetters.contains(guessLetter) && !matchedLetters.contains(guessLetter) {
                    misplacedLetters.append(guessLetter)
                    
                    // Set the key color.
                    keyColors[guessLetter] = .misplaced
                }
                frequency[guessLetter]! -= 1 // Decrement the frequency to account for this match.
            }
        }
        
        // Third pass: Identify and mark the keyboard keys based on their status.t
        for index in 0...4 {
            let guessLetter = guesses[tryIndex].guessLetters[index] // The guessed letter at the current index.
            
            // If the key isn't correct or misplaced, mark it wrong.
            if keyColors[guessLetter] != .correct && keyColors[guessLetter] != .misplaced {
                keyColors[guessLetter] = .wrong
            }
        }
        
        flipCards(for: tryIndex)
    }
    
    func flipCards(for row: Int) {
        for col in 0...4 {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(col) * 0.2) {
                self.guesses[row].cardFlipped[col].toggle()
            }
        }
    }
    
    func showToast(with text: String?) {
        withAnimation {
            toastText = text
        }
        
        withAnimation(Animation.linear(duration: 0.2).delay(3)) {
            toastText = nil
            if gameOver {
                withAnimation(Animation.linear(duration: 0.2).delay(3)) {
                    showStats.toggle()
                }
            }
        }
    }
    
    func shareResult() {
        let stat = Statistic.loadStat()
        let results = guesses.enumerated().compactMap { $0 }
        var guessString = ""
        for result in results {
            if result.0 <= tryIndex {
                guessString += result.1.results + "\n"
            }
        }
        let resultString = """
Wordle \(stat.games) \(tryIndex < 6 ? "\(tryIndex + 1)/6" : "")
\(guessString)
"""
        
        let activityController = UIActivityViewController(activityItems: [resultString], applicationActivities: nil)
        switch UIDevice.current.userInterfaceIdiom {
        case .phone:
            UIWindow.key?.rootViewController!
                .present(activityController, animated: true)
        case .pad:
            activityController.popoverPresentationController?.sourceView = UIWindow.key
            activityController.popoverPresentationController?.sourceRect = CGRect(x: Global.screenWidth / 2,
                                                                                  y: Global.screenHeight / 2,
                                                                                  width: 200,
                                                                                  height: 200)
            UIWindow.key?.rootViewController!.present(activityController, animated: true)
        default:
            break
        }
    }
}
