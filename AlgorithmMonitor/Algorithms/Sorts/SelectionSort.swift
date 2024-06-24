//
//  SelectionSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class SelectionSort: Sortable {
    private(set) var array: [Int]
    private(set) var confirmedIndices: [Int] = []
    private var currentI: Int = 0
    private var currentJ: Int = 0
    private var minIndex: Int = 0
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
                    
                    while currentI < n - 1 {
                        if currentJ == currentI {
                            minIndex = currentI
                        }
                        
                        while currentJ < n {
                            guard !isPaused && !isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            calculationAmount += 1
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: [currentJ], matchedIndices: [currentI, minIndex])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            if array[currentJ] < array[minIndex] {
                                minIndex = currentJ
                                if needsAnimation {
                                    yieldUpdate(continuation: continuation, selectedIndices: [currentJ], matchedIndices: [currentI, minIndex])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                }
                            }
                            currentJ += 1
                        }
                        
                        array.swapAt(currentI, minIndex)
                        confirmedIndices.append(currentI)
                        currentI += 1
                        currentJ = currentI
                        
                        if currentI == n - 1 {
                            completeSort(continuation: continuation)
                        } else {
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: [currentI])
                            }
                        }
                    }
                } catch {
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
                    let n = array.count
                    guard !isCompleted  && currentI < n - 1 else {
                        continuation.finish()
                        return
                    }
                    
                    if currentJ == currentI {
                        minIndex = currentI
                    }
                    while currentJ < n {
                        guard !isCompleted && !isPaused else {
                            continuation.finish()
                            return
                        }
                        try Task.checkCancellation()
                        
                        calculationAmount += 1
                        if needsAnimation {
                            yieldUpdate(continuation: continuation, selectedIndices: [currentI, currentJ], matchedIndices: [minIndex])
                            try await Task.sleep(nanoseconds: 200_000_000)
                        }
                        if array[currentJ] < array[minIndex] {
                            minIndex = currentJ
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: [currentI], matchedIndices: [minIndex])
                                try await Task.sleep(nanoseconds: 200_000_000)
                            }
                        }
                        currentJ += 1
                    }
                    
                    array.swapAt(currentI, minIndex)
                    confirmedIndices.append(currentI)
                    currentI += 1
                    currentJ = currentI
                    
                    if currentI == n - 1 {
                        completeSort(continuation: continuation)
                    } else {
                        yieldUpdate(continuation: continuation, selectedIndices: [currentI])
                        isPaused = false
                        continuation.finish()
                    }
                } catch {
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
