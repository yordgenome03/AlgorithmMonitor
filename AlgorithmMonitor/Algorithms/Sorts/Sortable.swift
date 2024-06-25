//
//  Sortable.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

protocol Sortable {
    var array: [Int] { get }
    init(array: [Int], needsAnimation: Bool)
    func sort() -> AsyncStream<SortUpdate?>
    func stepForward() -> AsyncStream<SortUpdate?>
    func stop()
    func reset()
}
