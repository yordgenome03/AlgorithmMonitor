//
//  LinearSearch.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class LinearSearch: Searchable {
    private let helper: SearchHelper
    
    var array: [Int] {
        get { return helper.array }
        set { helper.array = newValue }
    }
    
    var target: Int {
        return helper.target
    }
    
    required init(array: [Int], target: Int, needsAnimation: Bool) {
        self.helper = SearchHelper(array: array, target: target, needsAnimation: needsAnimation)
    }
    
    func search() -> AsyncStream<SearchUpdate?> {
        helper.isPaused = false
        return AsyncStream { continuation in
            helper.searchTask = Task {
                do {
                    let waitTimeForCalculation: UInt64 = UInt64(150_000_000)
                    
                    while helper.currentIndex ?? 0 < helper.array.count {
                        guard !helper.isPaused && !helper.found else {
                            continuation.finish()
                            return
                        }
                        
                        if helper.currentIndex == nil {
                            helper.currentIndex = 0
                        }
                        helper.searchedIndices.append(helper.currentIndex!)
                        if helper.needsAnimation {
                            helper.yieldUpdate(continuation: continuation, currentIndex: helper.currentIndex)
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                        }
                        
                        if helper.array[helper.currentIndex!] == helper.target {
                            helper.completeSearch(continuation: continuation, currentIndex: helper.currentIndex)
                            return
                        } else {
                            helper.currentIndex! += 1
                            if helper.needsAnimation {
                                helper.yieldUpdate(continuation: continuation, currentIndex: helper.currentIndex)
                                try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            }
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
                    let waitTimeForCalculation: UInt64 = UInt64(150_000_000)
                    while helper.currentIndex ?? 0 < helper.array.count {
                        guard !helper.found && !helper.isPaused else {
                            continuation.finish()
                            return
                        }
                        if helper.currentIndex == nil {
                            helper.currentIndex = 0
                        }
                        helper.searchedIndices.append(helper.currentIndex!)
                        if helper.array[helper.currentIndex!] == helper.target {
                            helper.completeSearch(continuation: continuation, currentIndex: helper.currentIndex)
                        } else {
                            helper.yieldUpdate(continuation: continuation, currentIndex: helper.currentIndex)
                            try await Task.sleep(nanoseconds: waitTimeForCalculation)
                            helper.currentIndex! += 1
                        }
                    }
                    helper.completeSearch(continuation: continuation)
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
        helper.cancelSearch()
    }
}
