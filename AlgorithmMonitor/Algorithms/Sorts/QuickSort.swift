//
//  QuickSort.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class QuickSort: Sortable {
    private let helper: SortHelper
    private var stack: [(Int, Int)] = []

    var array: [Int] {
        return helper.array
    }

    required init(array: [Int], needsAnimation: Bool) {
        self.helper = SortHelper(array: array, needsAnimation: needsAnimation)
        self.stack = [(0, array.count - 1)]
    }

    func sort() -> AsyncStream<SortUpdate?> {

        helper.isPaused = false
        return AsyncStream { continuation in
            helper.sortingTask = Task(priority: .userInitiated) {
                do {
                    let n = helper.array.count
                    let waitTimeForCalculation: UInt64 = UInt64(10_000_000_000) / UInt64(n * (n - 1) / 2)
                    
                    while let (low, high) = stack.popLast() {
                        guard !helper.isPaused && !helper.isCompleted else {
                            continuation.finish()
                            return
                        }
                        if low < high {
                            let pivotIndex = try await partition(low: low, high: high, continuation: continuation)
                            helper.confirmedIndices.append(pivotIndex)
                            helper.yieldUpdate(continuation: continuation)
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            if pivotIndex < array.count {
                                stack.append((pivotIndex + 1, high))
                            }
                            if pivotIndex > 0 {
                                stack.append((low, pivotIndex - 1))
                            }
                        } else {
                            helper.confirmedIndices.append(contentsOf: [low, high])
                            helper.yieldUpdate(continuation: continuation)
                        }
                    }
                    helper.completeSort(continuation: continuation)
                } catch {
                    continuation.finish()
                }
            }
        }
    }

    private func partition(low: Int, high: Int, continuation: AsyncStream<SortUpdate?>.Continuation) async throws -> Int {
        let n = helper.array.count
        let waitTimeForCalculation: UInt64 = UInt64(10_000_000_000) / UInt64(n * (n - 1) / 2)
        
        let pivot = helper.array[high]
        helper.yieldUpdate(continuation: continuation, matchedIndices: [high])
        try await Task.sleep(nanoseconds: waitTimeForCalculation)
        var selectedIndices = Array(low..<high)
        var i = low
        for j in low..<high {
            guard !helper.isPaused && !helper.isCompleted else {
                continuation.finish()
                throw CancellationError()
            }
            helper.calculationAmount += 1
            if helper.needsAnimation {
                helper.yieldUpdate(continuation: continuation,
                                   selectedIndices: selectedIndices,
                                   matchedIndices: [high, i, j])
                try await Task.sleep(nanoseconds: waitTimeForCalculation)
            }
            if helper.array[j] < pivot {
                helper.yieldUpdate(continuation: continuation,
                                   selectedIndices: selectedIndices,
                                   matchedIndices: [high, i, j])
                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                helper.array.swapAt(i, j)
                helper.yieldUpdate(continuation: continuation,
                                   selectedIndices: selectedIndices,
                                   matchedIndices: [high, i, j])
                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                i += 1
            }
        }
        helper.confirmedIndices.append(i)
        helper.array.swapAt(i, high)
        helper.yieldUpdate(continuation: continuation,
                           selectedIndices: selectedIndices)
        try await Task.sleep(nanoseconds: waitTimeForCalculation)
        return i
    }

    func stepForward() -> AsyncStream<SortUpdate?> {
        helper.isPaused = false
        return AsyncStream { continuation in
            helper.sortingTask = Task(priority: .userInitiated) {
                do {
                    if let (low, high) = stack.popLast() {
                        guard !helper.isPaused && !helper.isCompleted else {
                            continuation.finish()
                            return
                        }
                        if low < high {
                            let pivotIndex = try await partition(low: low, high: high, continuation: continuation)
                            helper.confirmedIndices.append(pivotIndex)
                            if pivotIndex < array.count {
                                stack.append((pivotIndex + 1, high))
                            }
                            if pivotIndex > 0 {
                                stack.append((low, pivotIndex - 1))
                            }
                        } else {
                            helper.confirmedIndices.append(high)
                            helper.yieldUpdate(continuation: continuation)
                        }
                        if stack.isEmpty {
                            helper.completeSort(continuation: continuation)
                        } else {
                            helper.yieldUpdate(continuation: continuation)
                        }
                    }
                    continuation.finish()
                } catch {
                    continuation.finish()
                }
            }
        }
    }

    func stop() {
        // FIXME: 停止→再開時にソートが完了しないので修正する
//        helper.isPaused = true
    }

    func reset() {
        helper.isPaused = true
        helper.cancelSort()
        stack = [(0, helper.array.count - 1)]
    }
}
