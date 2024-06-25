//
//  BubbleSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class BubbleSort: Sortable {
    private let helper: SortHelper
    private var currentI: Int = 0
    private var currentJ: Int = 0

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
                    
                    for i in currentI..<n {
                        for j in currentJ..<n - i - 1 {
                            guard !helper.isPaused && !helper.isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            helper.calculationAmount += 1
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            if helper.array[j] > helper.array[j + 1] {
                                if helper.needsAnimation {
                                    helper.yieldUpdate(continuation: continuation, matchedIndices: [currentJ, currentJ + 1])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                }
                                helper.array.swapAt(j, j + 1)
                                if helper.needsAnimation {
                                    helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation * 2)
                                }
                            }
                            currentJ += 1
                        }
                        helper.confirmedIndices.append(currentJ)
                        currentJ = 0
                        currentI += 1
                        if currentI == n - 1 {
                            helper.completeSort(continuation: continuation)
                        } else {
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ])
                            }
                        }
                    }
                } catch {
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
                    if currentI < n {
                        while currentJ < n - currentI - 1 {
                            guard !helper.isCompleted && !helper.isPaused else {
                                continuation.finish()
                                return
                            }
                            
                            helper.calculationAmount += 1
                            helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                            try await Task.sleep(nanoseconds: 200_000_000)
                            
                            if helper.array[currentJ] > helper.array[currentJ + 1] {
                                helper.yieldUpdate(continuation: continuation, matchedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: 200_000_000)
                                helper.array.swapAt(currentJ, currentJ + 1)
                                helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: 200_000_000)
                            }
                            currentJ += 1
                        }
                        
                        helper.confirmedIndices.append(currentJ)
                        currentJ = 0
                        currentI += 1
                        
                        if currentI == n - 1 {
                            helper.completeSort(continuation: continuation)
                        } else {
                            helper.yieldUpdate(continuation: continuation, selectedIndices: [currentJ])
                        }
                    }
                    helper.isPaused = false
                    continuation.finish()
                } catch {
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
