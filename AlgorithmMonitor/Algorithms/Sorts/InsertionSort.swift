//
//  SelectionSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class InsertionSort: Sortable {
    private let helper: SortHelper
    private var currentI: Int = 1
    private var currentJ: Int = 1
    private var selectedIndices: [Int] = []
    
    var array: [Int] {
        return helper.array
    }
    
    required init(array: [Int], needsAnimation: Bool) {
        self.helper = SortHelper(array: array, needsAnimation: needsAnimation)
    }
    
    func sort() -> AsyncStream<SortUpdate?> {
        helper.isPaused = false
        return AsyncStream { continuation in
            helper.sortingTask = Task(priority: .userInitiated) {
                do {
                    let n = helper.array.count
                    let waitTimeForCalculation: UInt64 = UInt64(10_000_000_000) / UInt64(n * (n - 1) / 2)
                    
                    while currentI < n {
                        selectedIndices = [currentI]
                        while currentJ > 0 && helper.array[currentJ] < helper.array[currentJ - 1] {
                            guard !helper.isPaused && !helper.isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            helper.calculationAmount += 1
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation,
                                                   selectedIndices: selectedIndices,
                                                   matchedIndices: [currentJ, currentJ - 1])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            helper.array.swapAt(currentJ, currentJ - 1)
                            if helper.needsAnimation {
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                
                                helper.yieldUpdate(continuation: continuation,
                                                   selectedIndices: selectedIndices)
                            }
                            currentJ -= 1
                        }
                        
                        currentI += 1
                        currentJ = currentI
                        selectedIndices = [currentI]
                        
                        if currentI == n {
                            helper.completeSort(continuation: continuation)
                        } else {
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, selectedIndices: selectedIndices)
                            }
                        }
                    }
                } catch {
                    currentJ += 1
                    helper.isPaused = false
                    continuation.finish()
                }
            }
        }
    }
    
    func stepForward() -> AsyncStream<SortUpdate?> {
        helper.isPaused = false
        
        return AsyncStream { continuation in
            helper.sortingTask = Task(priority: .userInitiated) {
                do {
                    guard !helper.isCompleted else {
                        continuation.finish()
                        return
                    }
                    let n = helper.array.count
                    selectedIndices = [currentI]
                    
                    while currentJ > 0 && helper.array[currentJ] < helper.array[currentJ - 1] {
                        guard !helper.isCompleted  && !helper.isPaused else {
                            continuation.finish()
                            return
                        }
                        
                        helper.calculationAmount += 1
                        if helper.needsAnimation {
                            helper.yieldUpdate(continuation: continuation,
                                               selectedIndices: selectedIndices,
                                               matchedIndices: [currentJ, currentJ - 1])
                            try await Task.sleep(nanoseconds: 200_000_000)
                        }
                        helper.array.swapAt(currentJ, currentJ - 1)
                        if helper.needsAnimation {
                            try await Task.sleep(nanoseconds: 200_000_000)
                            helper.yieldUpdate(continuation: continuation, selectedIndices: selectedIndices)
                        }
                        currentJ -= 1
                    }
                    currentI += 1
                    currentJ = currentI
                    
                    if currentI == n {
                        helper.completeSort(continuation: continuation)
                    } else {
                        if helper.needsAnimation {
                            helper.yieldUpdate(continuation: continuation, selectedIndices: selectedIndices
                            )
                        }
                    }
                    helper.isPaused = false
                    continuation.finish()
                } catch {
                    currentJ += 1
                    helper.isPaused = false
                    continuation.finish()
                }
            }
        }
    }
    
    func stop() {
        helper.isPaused = true
    }
    
    func reset() {
        helper.isPaused = true
        helper.cancelSort()
    }
}
