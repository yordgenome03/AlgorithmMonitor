//
//  BubbleSortViewModel.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

@MainActor
class BubbleSortViewModel: ObservableObject {
    @Published var initialArray: [Int] = []
    @Published var array: [Int] = []
    @Published var arrayCount: Int = 10
    @Published var selectedIndices: [Int] = []
    @Published var matchedIndices: [Int] = []
    @Published var confirmedIndices: [Int] = []
    @Published var needsAnimation: Bool = true
    @Published private(set) var confirmedNeedsAnimation: Bool = true
    @Published private(set) var confirmedArrayCount: Int = 10
    @Published var calculationAmount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isSorting: Bool = false
    @Published var isStepping: Bool = false
    
    private var bubbleSort: BubbleSort?
    
    init() {
        initializeArray()
    }
    
    private func initializeArray() {
        array = Array(1...confirmedArrayCount).shuffled()
        resetSortingState()
    }
    
    func startSort() async {
        if bubbleSort == nil {
            bubbleSort = BubbleSort(array: array, needsAnimation: needsAnimation)
        }
        isSorting = true
        isCompleted = false
        for await update in bubbleSort!.sort() {
            applyUpdate(update)
        }
        isSorting = false
    }
    
    func stopSort() {
        bubbleSort?.stop()
        isSorting = false
        isCompleted = false
    }
    
    func resetArray() {
        stopSort()
        initializeArray()
        resetSortingState()
    }
    
    func applySettings() {
        confirmedNeedsAnimation = needsAnimation
        confirmedArrayCount = arrayCount
        resetArray()
    }
    
    func stepForward() async {
        guard !isStepping && !isSorting && !isCompleted else { return }
        isStepping = true
        
        if bubbleSort == nil {
            bubbleSort = BubbleSort(array: array, needsAnimation: needsAnimation)
        }
        
        for await update in bubbleSort!.stepForward() {
            applyUpdate(update)
        }
        isStepping = false
    }
    
    private func applyUpdate(_ update: BubbleSortUpdate?) {
        if let update = update {
            self.array = update.array
            self.selectedIndices = update.selectedIndices
            self.matchedIndices = update.matchedIndices
            self.confirmedIndices = update.confirmedIndices
            self.calculationAmount = update.calculationAmount
            self.isCompleted = update.isCompleted
        }
    }
    
    private func resetSortingState() {
        selectedIndices = []
        matchedIndices = []
        confirmedIndices = []
        isSorting = false
        isCompleted = false
        isStepping = false
        calculationAmount = 0
        bubbleSort = nil
    }
}
