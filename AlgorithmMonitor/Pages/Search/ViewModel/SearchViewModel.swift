//
//  SearchViewModel.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

@MainActor
class SearchViewModel<T: Searchable>: ObservableObject {
    @Published var array: [Int] = []
    @Published var arrayCount: Int = 30
    @Published var target: Int = 7
    @Published var searchedIndices: [Int] = []
    @Published var currentIndex: Int?
    @Published var found: Bool = false
    @Published var isSearching: Bool = false
    @Published var needsAnimation: Bool = true
    @Published private(set) var confirmedNeedsAnimation: Bool = true {
        didSet {
            needsAnimation = confirmedNeedsAnimation
        }
    }
    @Published private(set) var confirmedArrayCount: Int = 30 {
        didSet {
            arrayCount = confirmedArrayCount
        }
    }
    @Published private(set) var confirmedTarget: Int = 7 {
        didSet {
            target = confirmedTarget
        }
    }
    @Published var calculationAmount: Int = 0
    
    private let settingsRepository: SettingsRepositoryProtocol
    private var searcher: T?
    
    init(settingsRepository: SettingsRepositoryProtocol = SettingsRepository.shared) {
        self.settingsRepository = settingsRepository
        loadSettings()
        initializeArray()
    }
    
    private func loadSettings() {
        let (needsAnimation, arrayCount, target) = settingsRepository.loadSearchSettings()
        confirmedNeedsAnimation = needsAnimation
        confirmedArrayCount = arrayCount
        confirmedTarget = target
    }
    
    func initializeArray() {
        array = Array(1...confirmedArrayCount).shuffled()
    }
    
    func startSearch() async {
        await runSearchTask { self.searcher?.search() }
    }
    
    func stepForward() async {
        guard !isSearching && !found else { return }
        await runSearchTask { self.searcher?.stepForward() }
    }
    
    private func runSearchTask(_ searchTask: @escaping () -> AsyncStream<SearchUpdate?>?) async {
        ensureSearcher()
        guard let stream = searchTask() else {
            return
        }
        isSearching = true
        found = false
        for await update in stream {
            applyUpdate(update)
        }
        isSearching = false
    }
    
    private func ensureSearcher() {
        if searcher == nil {
            searcher = T(array: array, target: target, needsAnimation: confirmedNeedsAnimation)
        }
    }
    
    func stopSearch() {
        searcher?.stop()
        isSearching = false
    }
    
    func resetArray() {
        resetSearchState()
        initializeArray()
    }
    
    func applySettings() {
        settingsRepository.saveSearchSettings(needsAnimation: needsAnimation, 
                                              arrayCount: arrayCount,
                                              target: target)
        loadSettings()
        resetArray()
    }
    
    private func applyUpdate(_ update: SearchUpdate?) {
        if let update = update {
            array = update.array
            currentIndex = update.currentIndex
            searchedIndices = update.searchedIndices
            found = update.found
        }
    }
    
    private func resetSearchState() {
        searcher?.reset()
        searcher = nil
        currentIndex = nil
        searchedIndices.removeAll()
        found = false
        isSearching = false
    }
}
