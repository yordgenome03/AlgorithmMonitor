//
//  BubbleSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class BubbleSort: Sortable {
    private(set) var array: [Int]
    private(set) var confirmedIndices: [Int] = []
    private var currentI: Int = 0
    private var currentJ: Int = 0
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
                    
                    for i in currentI..<n {
                        for j in currentJ..<n - i - 1 {
                            guard !isPaused && !isCompleted else {
                                continuation.finish()
                                return
                            }
                            try Task.checkCancellation()
                            
                            calculationAmount += 1
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                            if array[j] > array[j + 1] {
                                if needsAnimation {
                                    yieldUpdate(continuation: continuation, matchedIndices: [currentJ, currentJ + 1])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation)
                                }
                                array.swapAt(j, j + 1)
                                if needsAnimation {
                                    yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                    try await Task.sleep(nanoseconds: waitTimeForCalculation * 2)
                                }
                            }
                            currentJ += 1
                        }
                        confirmedIndices.append(currentJ)
                        currentJ = 0
                        currentI += 1
                        if currentI == n - 1 {
                            completeSort(continuation: continuation)
                        } else {
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, selectedIndices: [currentJ])
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
        isPaused = false
        return AsyncStream { continuation in
            sortingTask = Task(priority: .userInitiated) {
                do {
                    guard !isCompleted else {
                        continuation.finish()
                        return
                    }
                    
                    let n = array.count
                    if currentI < n {
                        while currentJ < n - currentI - 1 {
                            guard !isCompleted && !isPaused else {
                                continuation.finish()
                                return
                            }
                            
                            calculationAmount += 1
                            yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                            try await Task.sleep(nanoseconds: 200_000_000)
                            
                            if array[currentJ] > array[currentJ + 1] {
                                yieldUpdate(continuation: continuation, matchedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: 200_000_000)
                                array.swapAt(currentJ, currentJ + 1)
                                yieldUpdate(continuation: continuation, selectedIndices: [currentJ, currentJ + 1])
                                try await Task.sleep(nanoseconds: 200_000_000)
                            }
                            currentJ += 1
                        }
                        
                        confirmedIndices.append(currentJ)
                        currentJ = 0
                        currentI += 1
                        
                        if currentI == n - 1 {
                            completeSort(continuation: continuation)
                        } else {
                            yieldUpdate(continuation: continuation, selectedIndices: [currentJ])
                        }
                    }
                    isPaused = false
                    continuation.finish()
                } catch {
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
