//
//  SelectionSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class SelectionSort: Sortable {
    private let helper: SortHelper
    private var currentI: Int = 0
    private var currentJ: Int = 0
    private var minIndex: Int = 0

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
                    
                    while currentI < n - 1 {
                        if currentJ == currentI {
                            minIndex = currentI
                        }
                        
                        while currentJ < n {
                            guard !helper.isPaused && !helper.isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            helper.calculationAmount += 1
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ], matchedIndices: [currentI, minIndex])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            if helper.array[currentJ] < helper.array[minIndex] {
                                minIndex = currentJ
                                if helper.needsAnimation {
                                    helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ], matchedIndices: [currentI, minIndex])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                }
                            }
                            currentJ += 1
                        }
                        
                        helper.array.swapAt(currentI, minIndex)
                        helper.confirmedIndices.append(currentI)
                        currentI += 1
                        currentJ = currentI
                        
                        if currentI == n - 1 {
                            helper.completeSort(continuation: continuation)
                        } else {
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, selectedIndices: [currentI])
                            }
                        }
                    }
                } catch {
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
                    let n = helper.array.count
                    guard !helper.isCompleted  && currentI < n - 1 else {
                        continuation.finish()
                        return
                    }
                    
                    if currentJ == currentI {
                        minIndex = currentI
                    }
                    while currentJ < n {
                        guard !helper.isCompleted && !helper.isPaused else {
                            continuation.finish()
                            return
                        }
                        try Task.checkCancellation()
                        
                        helper.calculationAmount += 1
                        helper.yieldUpdate(continuation: continuation, selectedIndices: [currentI, currentJ], matchedIndices: [minIndex])
                        try await Task.sleep(nanoseconds: 200_000_000)
                        if helper.array[currentJ] < helper.array[minIndex] {
                            minIndex = currentJ
                            helper.yieldUpdate(continuation: continuation, selectedIndices: [currentI], matchedIndices: [minIndex])
                            try await Task.sleep(nanoseconds: 200_000_000)
                        }
                        currentJ += 1
                    }
                    
                    helper.array.swapAt(currentI, minIndex)
                    helper.confirmedIndices.append(currentI)
                    currentI += 1
                    currentJ = currentI
                    
                    if currentI == n - 1 {
                        helper.completeSort(continuation: continuation)
                    } else {
                        helper.yieldUpdate(continuation: continuation, selectedIndices: [currentI])
                        helper.isPaused = false
                        continuation.finish()
                    }
                } catch {
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
