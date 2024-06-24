//
//  SelectionSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class InsertionSort: Sortable {
    private(set) var array: [Int]
    private(set) var confirmedIndices: [Int] = []
    private var currentI: Int = 1
    private var currentJ: Int = 1
    private var selectedIndices: [Int] = []
    private var calculationAmount: Int = 0
    private var isPaused: Bool = false
    private var isCompleted: Bool = false
    private let needsAnimation: Bool
    private var sortingTask: Task<Void, Never>? = nil
    
    required init(array: [Int], needsAnimation: Bool) {
        self.array = array
        self.needsAnimation = needsAnimation
    }
    
    func sort() -> AsyncStream<SortUpdate?> {
        isPaused = false
        return AsyncStream { continuation in
            sortingTask = Task(priority: .userInitiated) {
                do {
                    
                    let n = array.count
                    let waitTimeForCalculation: UInt64 = UInt64(10_000_000_000) / UInt64(n * (n - 1) / 2)
                    
                    while currentI < n {
                        selectedIndices = [currentI]
                        while currentJ > 0 && array[currentJ] < array[currentJ - 1] {
                            guard !isPaused && !isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            calculationAmount += 1
                            if needsAnimation {
                                yieldUpdate(continuation: continuation,
                                            selectedIndices: selectedIndices,
                                            matchedIndices: [currentJ, currentJ - 1])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            array.swapAt(currentJ, currentJ - 1)
                            if needsAnimation {
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                
                                yieldUpdate(continuation: continuation,
                                            selectedIndices: selectedIndices)
                            }
                            currentJ -= 1
                        }
                        
                        currentI += 1
                        currentJ = currentI
                        selectedIndices = [currentI]
                        
                        if currentI == n {
                            completeSort(continuation: continuation)
                        } else {
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: selectedIndices)
                            }
                        }
                    }
                } catch {
                    currentJ += 1
                    isPaused = false
                    continuation.finish()
                }
            }
        }
    }
    
    func stepForward() -> AsyncStream<SortUpdate?> {
        isPaused = false
        
        return AsyncStream { continuation in
            sortingTask = Task(priority: .userInitiated) {
                do {
                    guard !isCompleted else {
                        continuation.finish()
                        return
                    }
                    let n = array.count
                    selectedIndices = [currentI]
                    
                    while currentJ > 0 && array[currentJ] < array[currentJ - 1] {
                        guard !isCompleted  && !isPaused else {
                            continuation.finish()
                            return
                        }
                        
                        calculationAmount += 1
                        if needsAnimation {
                            yieldUpdate(continuation: continuation,
                                        selectedIndices: selectedIndices,
                                        matchedIndices: [currentJ, currentJ - 1])
                            try await Task.sleep(nanoseconds: 200_000_000)
                        }
                        array.swapAt(currentJ, currentJ - 1)
                        if needsAnimation {
                            try await Task.sleep(nanoseconds: 200_000_000)
                            yieldUpdate(continuation: continuation, selectedIndices: selectedIndices)
                        }
                        currentJ -= 1
                    }
                    currentI += 1
                    currentJ = currentI
                    
                    if currentI == n {
                        completeSort(continuation: continuation)
                    } else {
                        if needsAnimation {
                            yieldUpdate(continuation: continuation, selectedIndices: selectedIndices
                            )
                        }
                    }
                    isPaused = false
                    continuation.finish()
                } catch {
                    currentJ += 1
                    isPaused = false
                    continuation.finish()
                }
            }
        }
    }
    
    func stop() {
        isPaused = true
    }
    
    private func yieldUpdate(continuation: AsyncStream<SortUpdate?>.Continuation,
                             selectedIndices: [Int] = [],
                             matchedIndices: [Int] = []) {
        let update = SortUpdate(array: array,
                                selectedIndices: selectedIndices,
                                matchedIndices: matchedIndices,
                                confirmedIndices: confirmedIndices,
                                calculationAmount: calculationAmount,
                                isCompleted: isCompleted)
        continuation.yield(update)
    }
    
    private func completeSort(continuation: AsyncStream<SortUpdate?>.Continuation) {
        isCompleted = true
        let update = SortUpdate(array: array,
                                selectedIndices: [],
                                matchedIndices: [],
                                confirmedIndices: confirmedIndices,
                                calculationAmount: calculationAmount,
                                isCompleted: isCompleted)
        continuation.yield(update)
        continuation.finish()
    }
}
