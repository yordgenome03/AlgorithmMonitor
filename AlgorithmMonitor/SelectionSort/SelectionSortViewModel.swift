//
//  SelectionSortViewModel.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

@MainActor
class SelectionSortViewModel: ObservableObject {
    @Published var array: [Int] = []
    @Published var activeIndices: (Int, Int, Int)? = nil
    @Published var arrayCount: Int = 10
    @Published var needsAnimation: Bool = true
    @Published private(set) var confirmedNeedsAnimation: Bool = true
    @Published private(set) var confirmedArrayCount: Int = 10
    @Published var calculationAmount: Int = 0
    @Published var isCompleted: Bool = false
    @Published var isSorting: Bool = false
    
    private var currentI: Int = 0
    private var currentJ: Int = 1
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
        await selectionSort()
    }
    
    func stopSort() {
        isPaused = true
        isSorting = false
    }
    
    private func selectionSort() async {
        let n = array.count
        let waitTime: UInt64 = UInt64(5_000_000_000)
        let waitTimeForCalculation = waitTime / UInt64(n * (n - 1) / 2)

        for i in currentI..<n {
            var minIndex = i
            for j in currentJ..<n {
                guard !isPaused else {
                    saveCurrentState(i: i, j: j)
                    return
                }
                activeIndices = (i, minIndex, j)
                if needsAnimation {
                    await updateArray()
                }
                if array[j] < array[minIndex] {
                    minIndex = j
                }
                calculationAmount += 1
                if needsAnimation {
                    try? await Task.sleep(nanoseconds: waitTimeForCalculation)
                }
            }
            array.swapAt(i, minIndex)
            if needsAnimation {
                await updateArray()
            }
            activeIndices = nil
            calculationAmount += 1
            currentJ = i + 1
            currentI += 1
        }
        await updateArray()
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
        confirmedArrayCount = arrayCount
        confirmedNeedsAnimation = needsAnimation
        resetArray()
    }
    
    func stepForward() async {
        guard !isSorting, currentI < array.count else { return }
        
        isSorting = true
        isPaused = false
        
        await selectionSortStep()
    }
    
    private func selectionSortStep() async {
        let n = array.count
        
        if currentI < n {
            var minIndex = currentI
            for j in (currentJ..<n) {
                activeIndices = (currentI, minIndex, j)
                await updateArray()

                if array[j] < array[minIndex] {
                    minIndex = j
                }
                try? await Task.sleep(nanoseconds: 500_000_000)
            }
            array.swapAt(currentI, minIndex)
            calculationAmount += 1
            currentI += 1
            currentJ = currentI + 1
            activeIndices = (currentI, currentJ, currentJ)
            await updateArray()
        }
        isSorting = false
        
        if currentI == n - 1 {
            completeSorting()
        }
    }
    
    private func saveCurrentState(i: Int, j: Int) {
        currentI = i
        currentJ = j
    }
    
    private func resetSortingState() {
        currentI = 0
        currentJ = 1
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
