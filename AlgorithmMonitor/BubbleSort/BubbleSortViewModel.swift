//
//  BubbleSortViewModel.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

@MainActor
class BubbleSortViewModel: ObservableObject {
    @Published var initialArray: [Int] = []
    @Published var array: [Int] = []
    @Published var arrayCount: Int = 10
    @Published var activeIndices: (Int, Int)? = nil
    @Published var needsAnimation: Bool = true
    @Published private(set) var confirmedNeedsAnimation: Bool = true
    @Published private(set) var confirmedArrayCount: Int = 10
    @Published var calculationAmount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isSorting: Bool = false
    
    private var currentI: Int = 0
    private var currentJ: Int = 0
    private var isPaused: Bool = true
    
    init() {
        initializeArray()
    }
    
    private func initializeArray() {
        array = Array(1...confirmedArrayCount).shuffled()
        resetSortingState()
    }
    
    func startSort() async {
        isSorting = true
        isPaused = false
        await bubbleSort()
    }
    
    func stopSort() {
        isPaused = true
        isSorting = false
    }
    
    private func bubbleSort() async {
        let n = array.count
        let waitTime: UInt64 = UInt64(5_000_000_000)
        let waitTimeForCalculation = waitTime / UInt64(n * (n - 1) / 2)
        
        for i in currentI..<n {
            for j in currentJ..<(n - i - 1) {
                guard !isPaused else {
                    saveCurrentState(i: i, j: j)
                    return
                }
                setActiveIndices(j, j + 1)
                if needsAnimation {
                    await updateArray()
                    try? await Task.sleep(nanoseconds: waitTimeForCalculation)
                }
                calculationAmount += 1
                if array[j] > array[j + 1] {
                    array.swapAt(j, j + 1)
                    if needsAnimation {
                        await updateArray()
                        try? await Task.sleep(nanoseconds: waitTimeForCalculation)
                    }
                }
                currentJ += 1
            }
            currentJ = 0
            currentI += 1
        }
        completeSorting()
    }

    
    private func updateArray() async {
        await MainActor.run {
            objectWillChange.send()
        }
    }
    
    func resetArray() {
        initializeArray()
        resetSortingState()
    }
    
    func applySettings() {
        confirmedNeedsAnimation = needsAnimation
        confirmedArrayCount = arrayCount
        resetArray()
    }
    
    func stepForward() async {
        guard !isSorting, currentI < array.count else { return }
        
        isPaused = false
        
        await bubbleSortStep()
    }
    
    private func bubbleSortStep() async {
        let n = array.count
        
        if currentJ < n - currentI - 1 {
            setActiveIndices(currentJ, currentJ + 1)
            await updateArray()
            try? await Task.sleep(nanoseconds: 500_000_000)

            if array[currentJ] > array[currentJ + 1] {
                array.swapAt(currentJ, currentJ + 1)
                await updateArray()
            }
            calculationAmount += 1
            currentJ += 1
        } else {
            currentJ = 0
            currentI += 1
        }
    }
    
    private func setActiveIndices(_ index1: Int, _ index2: Int) {
        activeIndices = (index1, index2)
    }
    
    private func saveCurrentState(i: Int, j: Int) {
        currentI = i
        currentJ = j
    }
    
    private func resetSortingState() {
        currentI = 0
        currentJ = 0
        calculationAmount = 0
        activeIndices = nil
        isSorting = false
        isPaused = true
        isCompleted = false
    }
    
    private func completeSorting() {
        activeIndices = nil
        isSorting = false
        isCompleted = true
    }
}
