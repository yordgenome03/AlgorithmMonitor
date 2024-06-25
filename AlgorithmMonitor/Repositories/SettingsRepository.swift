//
//  SettingsRepository.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

protocol SettingsRepositoryProtocol {
    var needsAnimation: Bool { get set }
    var arrayCountForSort: Int { get set }
    
    func saveSortSettings(needsAnimation: Bool, arrayCount: Int)
    func loadSortSettings() -> (needsAnimation: Bool, arrayCount: Int)
    func saveSearchSettings(needsAnimation: Bool, arrayCount: Int, target: Int)
    func loadSearchSettings() -> (needsAnimation: Bool, arrayCount: Int, target: Int)
}

class SettingsRepository: SettingsRepositoryProtocol {
    static let shared = SettingsRepository()
    
    private let userDefaults = UserDefaults.standard
    private let needsAnimationKey = "NeedsAnimation"
    private let arrayCountKeyForSort = "ArrayCountForSort"
    private let arrayCountKeyForSearch = "ArrayCountForSearch"
    private let searchTargetKey = "SearchTargetKey"
    
    init() {
        userDefaults.register(defaults: [
            needsAnimationKey: true,
            arrayCountKeyForSort: 15,
            arrayCountKeyForSearch: 30,
            searchTargetKey: 7
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
    
    var arrayCountForSort: Int {
        get {
            userDefaults.integer(forKey: arrayCountKeyForSort)
        }
        set {
            userDefaults.set(newValue, forKey: arrayCountKeyForSort)
        }
    }
    
    var arrayCountForSearch: Int {
        get {
            userDefaults.integer(forKey: arrayCountKeyForSearch)
        }
        set {
            userDefaults.set(newValue, forKey: arrayCountKeyForSearch)
        }
    }
    
    var searchTarget: Int {
        get {
            userDefaults.integer(forKey: searchTargetKey)
        }
        set {
            userDefaults.set(newValue, forKey: searchTargetKey)
        }
    }
    
    func saveSortSettings(needsAnimation: Bool, arrayCount: Int) {
        self.needsAnimation = needsAnimation
        self.arrayCountForSort = arrayCount
    }
    
    func loadSortSettings() -> (needsAnimation: Bool, arrayCount: Int) {
        let needsAnimation = self.needsAnimation
        let arrayCount = self.arrayCountForSort
        return (needsAnimation, arrayCount)
    }
    
    func saveSearchSettings(needsAnimation: Bool, arrayCount: Int, target: Int) {
        self.needsAnimation = needsAnimation
        self.arrayCountForSearch = arrayCount
        self.searchTarget = target
    }
    
    func loadSearchSettings() -> (needsAnimation: Bool, arrayCount: Int, target: Int) {
        let needsAnimation = self.needsAnimation
        let arrayCount = self.arrayCountForSearch
        let searchTarget = self.searchTarget
        return (needsAnimation, arrayCount, searchTarget)
    }
}
