//
//  SearchHelper.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class SearchHelper {
    var array: [Int]
    var target: Int
    var searchedIndices: [Int] = []
    var currentIndex: Int?
    var calculationAmount: Int = 0
    var isPaused: Bool = false
    var found: Bool = false
    let needsAnimation: Bool
    var searchTask: Task<Void, Never>? = nil
    
    init(array: [Int], target: Int, needsAnimation: Bool) {
        self.array = array
        self.target = target
        self.needsAnimation = needsAnimation
    }
    
    func yieldUpdate(continuation: AsyncStream<SearchUpdate?>.Continuation, currentIndex: Int? = nil) {
        let update = SearchUpdate(array: array,
                                  target: target,
                                  currentIndex: currentIndex,
                                  searchedIndices: searchedIndices,
                                  found: found)
        continuation.yield(update)
    }
    
    func completeSearch(continuation: AsyncStream<SearchUpdate?>.Continuation, currentIndex: Int? = nil) {
        found = true
        yieldUpdate(continuation: continuation, currentIndex: currentIndex)
        continuation.finish()
    }
    
    func cancelSearch() {
        searchTask?.cancel()
        searchTask = nil
    }
}
