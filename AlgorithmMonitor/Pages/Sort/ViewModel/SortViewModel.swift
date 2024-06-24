//
//  SortViewModel.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

@MainActor
class SortViewModel<T: Sortable>: ObservableObject {
    @Published var array: [Int] = []
    @Published var arrayCount: Int = 10
    @Published var selectedIndices: [Int] = []
    @Published var matchedIndices: [Int] = []
    @Published var confirmedIndices: [Int] = []
    @Published var needsAnimation: Bool = true
    @Published private(set) var confirmedNeedsAnimation: Bool = true {
        didSet {
            needsAnimation = confirmedNeedsAnimation
        }
    }
    @Published private(set) var confirmedArrayCount: Int = 10 {
        didSet {
            arrayCount = confirmedArrayCount
        }
    }
    @Published var calculationAmount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isSorting: Bool = false
    
    private let settingsRepository: SettingsRepositoryProtocol
    private var sorter: T?
    
    init(settingsRepository: SettingsRepositoryProtocol = SettingsRepository.shared) {
        self.settingsRepository = settingsRepository
        loadSettings()
        initializeArray()
    }
    
    private func loadSettings() {
        let (needsAnimation, arrayCount) = settingsRepository.loadSettings()
        confirmedNeedsAnimation = needsAnimation
        confirmedArrayCount = arrayCount
    }

    private func initializeArray() {
        array = Array(1...confirmedArrayCount).shuffled()
        resetSortingState()
    }
    
    func startSort() async {
        guard !isSorting && !isCompleted else { return }
        await runSortingTask { self.sorter?.sort() }
    }
    
    func stepForward() async {
        guard !isSorting && !isCompleted else { return }
        await runSortingTask { self.sorter?.stepForward() }
    }
    
    private func runSortingTask(_ sortTask: @escaping () -> AsyncStream<SortUpdate?>?) async {
        guard let sorter = ensureSorter(), let stream = sortTask() else { return }
        isSorting = true
        for await update in stream {
            applyUpdate(update)
        }
        isSorting = false
    }
    
    private func ensureSorter() -> T? {
        if sorter == nil {
            sorter = T(array: array, needsAnimation: needsAnimation)
        }
        return sorter
    }
    
    func stopSort() {
        sorter?.stop()
        isSorting = false
    }
    
    func resetArray() {
        stopSort()
        initializeArray()
        resetSortingState()
    }
    
    func applySettings() {
        settingsRepository.saveSettings(needsAnimation: needsAnimation, arrayCount: arrayCount)
        loadSettings()
        resetArray()
    }
    
    private func applyUpdate(_ update: SortUpdate?) {
        if let update = update {
            array = update.array
            selectedIndices = update.selectedIndices
            matchedIndices = update.matchedIndices
            confirmedIndices = update.confirmedIndices
            calculationAmount = update.calculationAmount
            isCompleted = update.isCompleted
        }
    }
    
    private func resetSortingState() {
        sorter = nil
        selectedIndices = []
        matchedIndices = []
        confirmedIndices = []
        isSorting = false
        isCompleted = false
        calculationAmount = 0
    }
}
