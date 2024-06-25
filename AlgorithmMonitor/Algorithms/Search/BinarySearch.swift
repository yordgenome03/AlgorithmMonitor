//
//  BinarySearch.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class BinarySearch: Searchable {
    private let helper: SearchHelper
    private var low: Int = 0
    private var high: Int
    
    var array: [Int] {
        get { return helper.array }
        set { helper.array = newValue }
    }
    
    var target: Int {
        return helper.target
    }
    
    required init(array: [Int], target: Int, needsAnimation: Bool) {
        self.helper = SearchHelper(array: array, target: target, needsAnimation: needsAnimation)
        self.high = array.count - 1
    }
    
    func search() -> AsyncStream<SearchUpdate?> {
        helper.isPaused = false
        return AsyncStream { continuation in
            helper.searchTask = Task {
                do {
                    let n = helper.array.count
                    let waitTimeForCalculation: UInt64 = UInt64(300_000_000)
                    
                    if helper.array != helper.array.sorted() {
                        helper.array = helper.array.sorted()
                        helper.yieldUpdate(continuation: continuation)
                        try await Task.sleep(nanoseconds: waitTimeForCalculation)
                    }
                    
                    while low <= high {
                        guard !helper.isPaused && !helper.found else {
                            continuation.finish()
                            return
                        }
                        
                        let mid = (low + high) / 2
                        if helper.needsAnimation {
                            helper.yieldUpdate(continuation: continuation, currentIndex: mid)
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                        }
                        
                        if helper.array[mid] == helper.target {
                            helper.completeSearch(continuation: continuation, currentIndex: mid)
                            return
                        } else if helper.array[mid] < helper.target {
                            helper.searchedIndices.append(contentsOf: Array(low...mid))
                            low = mid + 1
                        } else {
                            helper.searchedIndices.append(contentsOf: Array(mid...high))
                            high = mid - 1
                        }
                        
                        if helper.needsAnimation {
                            helper.yieldUpdate(continuation: continuation, currentIndex: mid)
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                        }
                    }
                    helper.completeSearch(continuation: continuation)
                } catch {
                    continuation.finish()
                }
            }
        }
    }
    
    func stepForward() -> AsyncStream<SearchUpdate?> {
        helper.isPaused = false
        return AsyncStream { continuation in
            helper.searchTask = Task {
                do {
                    let waitTimeForCalculation: UInt64 = UInt64(300_000_000)
                    
                    if helper.array != helper.array.sorted() {
                        helper.array = helper.array.sorted()
                        helper.yieldUpdate(continuation: continuation)
                        try await Task.sleep(nanoseconds: waitTimeForCalculation)
                    }
                    
                    guard !helper.found else {
                        continuation.finish()
                        return
                    }
                    
                    let mid = (low + high) / 2
                    helper.yieldUpdate(continuation: continuation, currentIndex: mid)
                    try await Task.sleep(nanoseconds: waitTimeForCalculation)
                    
                    if helper.array[mid] == helper.target {
                        helper.completeSearch(continuation: continuation, currentIndex: mid)
                    } else if helper.array[mid] < helper.target {
                        helper.searchedIndices.append(contentsOf: Array(low...mid))
                        low = mid + 1
                    } else {
                        helper.searchedIndices.append(contentsOf: Array(mid...high))
                        high = mid - 1
                    }
                    
                    helper.yieldUpdate(continuation: continuation, currentIndex: mid)
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
        helper.searchTask?.cancel()
    }
}


