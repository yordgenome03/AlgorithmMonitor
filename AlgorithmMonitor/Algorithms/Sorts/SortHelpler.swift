//
//  SortHelpler.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class SortHelper {
    var array: [Int]
    var confirmedIndices: [Int] = []
    var calculationAmount: Int = 0
    var isPaused: Bool = false
    var isCompleted: Bool = false
    let needsAnimation: Bool
    var sortingTask: Task<Void, Never>? = nil

    init(array: [Int], needsAnimation: Bool) {
        self.array = array
        self.needsAnimation = needsAnimation
    }

    func yieldUpdate(continuation: AsyncStream<SortUpdate?>.Continuation,
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

    func completeSort(continuation: AsyncStream<SortUpdate?>.Continuation) {
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
    
    func cancelSort() {
        sortingTask?.cancel()
        sortingTask = nil
    }
}
