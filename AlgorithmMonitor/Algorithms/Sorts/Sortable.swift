//
//  Sortable.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

struct SortUpdate {
    let array: [Int]
    let selectedIndices: [Int]
    let matchedIndices: [Int]
    let confirmedIndices: [Int]
    let calculationAmount: Int
    let isCompleted: Bool
}

protocol Sortable {
    var array: [Int] { get }
    init(array: [Int], needsAnimation: Bool)
    
    func sort() -> AsyncStream<SortUpdate?>
    func stepForward() -> AsyncStream<SortUpdate?>
    func stop()
}
