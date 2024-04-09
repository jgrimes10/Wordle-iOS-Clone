//
//  Statistic.swift
//  WordleClone
//
//  Created by Justin Grimes on 4/9/24.
//  Copyright © 2024 Justin Grimes. All rights reserved.
//

import Foundation

struct Statistic: Codable {
    var frequencies: [Int] = [Int](repeating: 0, count: 6)
    var games: Int = 0
    var streak: Int = 0
    var maxStreak: Int = 0
    
    var wins: Int {
        frequencies.reduce(0, +)
    }
    
    func saveStat() {
//        if let encoded = try? JSONEncoder().encode(self) {
//            UserDefaults.standard.set(encoded, forKey: "Stat")
//        }
        NSUbiquitousKeyValueStore.stat = self
    }
    
    static func loadStat() -> Statistic {
//        if let savedStat = UserDefaults.standard.object(forKey: "Stat") as? Data {
//            if let currentStat = try? JSONDecoder().decode(Statistic.self, from: savedStat) {
//                return currentStat
//            } else {
//                return Statistic()
//            }
//        } else {
//            return Statistic()
//        }
        NSUbiquitousKeyValueStore.stat
    }
    
    mutating func update(win: Bool, index: Int? = nil) {
        games += 1
        streak = win ? streak + 1 : 0
        
        if win {
            frequencies[index!] += 1
            maxStreak = max(maxStreak, streak)
        }
        
        saveStat()
    }
}
