//
//  BubbleSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

struct BubbleSortUpdate {
    let array: [Int]
    let activeIndices: (Int, Int)?
    let calculationAmount: Int
    let isCompleted: Bool
}

class BubbleSort {
    private(set) var array: [Int]
    private var currentI: Int = 0
    private var currentJ: Int = 0
    private(set) var calculationAmount: Int = 0
    private(set) var isPaused: Bool = false
    private(set) var isCompleted: Bool = false
    private let needsAnimation: Bool
    
    init(array: [Int], needsAnimation: Bool) {
        self.array = array
        self.needsAnimation = needsAnimation
    }
    
    func sort() -> AsyncStream<BubbleSortUpdate?> {
        isPaused = false
        return AsyncStream { continuation in
            Task {
                let n = array.count
                let waitTimeForCalculation: UInt64 = UInt64(10_000_000_000) / UInt64(n * (n - 1) / 2)
                
                for i in currentI..<n {
                    for j in currentJ..<n - i - 1 {
                        guard !isPaused && !isCompleted else {
                            continuation.finish()
                            return
                        }
                        calculationAmount += 1
                        if needsAnimation {
                            yieldUpdate(continuation: continuation, indices: (j, j + 1))
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                        }
                        if array[j] > array[j + 1] {
                            array.swapAt(j, j + 1)
                            if needsAnimation {
                                yieldUpdate(continuation: continuation, indices: (j, j + 1))
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
                        }
                        currentJ += 1
                    }
                    currentJ = 0
                    currentI += 1
                    if currentI == n - 1 {
                        completeSort(continuation: continuation)
                    } else {
                        if needsAnimation {
                            yieldUpdate(continuation: continuation, indices: (currentJ, currentJ))
                        }
                    }
                }
            }
        }
    }
    
    func stepForward() -> AsyncStream<BubbleSortUpdate?> {
        return AsyncStream { continuation in
            Task {
                guard !isCompleted else {
                    continuation.finish()
                    return
                }
                
                let n = array.count
                if currentI < n {
                    if currentJ < n - currentI - 1 {
                        calculationAmount += 1
                        yieldUpdate(continuation: continuation, indices: (currentJ, currentJ + 1))
                        try await Task.sleep(nanoseconds: 300_000_000)
                        
                        if array[currentJ] > array[currentJ + 1] {
                            array.swapAt(currentJ, currentJ + 1)
                            yieldUpdate(continuation: continuation, indices: (currentJ, currentJ + 1))
                            try await Task.sleep(nanoseconds: 300_000_000)
                        }
                        currentJ += 1
                    } else {
                        currentJ = 0
                        currentI += 1
                        
                        if currentI == n - 1 {
                            completeSort(continuation: continuation)
                        } else {
                            yieldUpdate(continuation: continuation, indices: (currentJ, currentJ))
                        }
                    }
                }
                isPaused = false
                continuation.finish()
            }
        }
    }
    
    func stop() {
        isPaused = true
    }
    
    private func yieldUpdate(continuation: AsyncStream<BubbleSortUpdate?>.Continuation, indices: (Int, Int)?) {
        let update = BubbleSortUpdate(array: array, activeIndices: indices, calculationAmount: calculationAmount, isCompleted: isCompleted)
        continuation.yield(update)
    }
    
    private func completeSort(continuation: AsyncStream<BubbleSortUpdate?>.Continuation) {
        isCompleted = true
        let update = BubbleSortUpdate(array: array, activeIndices: nil, calculationAmount: calculationAmount, isCompleted: isCompleted)
        continuation.yield(update)
        continuation.finish()
    }
}
