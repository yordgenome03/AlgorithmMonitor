//
//  SettingsRepository.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

protocol SettingsRepositoryProtocol {
    var needsAnimation: Bool { get set }
    var arrayCount: Int { get set }
    
    func saveSettings(needsAnimation: Bool, arrayCount: Int)
    func loadSettings() -> (needsAnimation: Bool, arrayCount: Int)
}

class SettingsRepository: SettingsRepositoryProtocol {
    static let shared = SettingsRepository()
    
    private let userDefaults = UserDefaults.standard
    private let needsAnimationKey = "NeedsAnimation"
    private let arrayCountKey = "ArrayCount"
    
    init() {
        userDefaults.register(defaults: [
            needsAnimationKey: true,
            arrayCountKey: 15
        ])
    }
    
    var needsAnimation: Bool {
        get {
            userDefaults.bool(forKey: needsAnimationKey)
        }
        set {
            userDefaults.set(newValue, forKey: needsAnimationKey)
        }
    }
    
    var arrayCount: Int {
        get {
            userDefaults.integer(forKey: arrayCountKey)
        }
        set {
            userDefaults.set(newValue, forKey: arrayCountKey)
        }
    }
    
    func saveSettings(needsAnimation: Bool, arrayCount: Int) {
        self.needsAnimation = needsAnimation
        self.arrayCount = arrayCount
    }
    
    func loadSettings() -> (needsAnimation: Bool, arrayCount: Int) {
        let needsAnimation = self.needsAnimation
        let arrayCount = self.arrayCount
        return (needsAnimation, arrayCount)
    }
}
