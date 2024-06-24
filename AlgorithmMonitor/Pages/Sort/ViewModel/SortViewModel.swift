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
    @Published private(set) var confirmedNeedsAnimation: Bool = true
    @Published private(set) var confirmedArrayCount: Int = 10
    @Published var calculationAmount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isSorting: Bool = false
    @Published var isStepping: Bool = false
    
    private var sorter: T?
    
    init() {
        initializeArray()
    }
    
    private func initializeArray() {
        array = Array(1...confirmedArrayCount).shuffled()
        resetSortingState()
    }
    
    func startSort() async {
        if sorter == nil {
            sorter = T(array: array, needsAnimation: needsAnimation)
        }
        isSorting = true
        isCompleted = false
        for await update in sorter!.sort() {
            applyUpdate(update)
        }
        isSorting = false
    }
    
    func stopSort() {
        sorter?.stop()
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
        
        if sorter == nil {
            sorter = T(array: array, needsAnimation: needsAnimation)
        }
        
        for await update in sorter!.stepForward() {
            applyUpdate(update)
        }
        isStepping = false
    }
    
    private func applyUpdate(_ update: SortUpdate?) {
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
        sorter = nil
    }
}
