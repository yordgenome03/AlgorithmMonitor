//
//  Searchable.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

protocol Searchable {
    var array: [Int] { get set }
    var target: Int { get }
    init(array: [Int], target: Int, needsAnimation: Bool)
    func search() -> AsyncStream<SearchUpdate?>
    func stepForward() -> AsyncStream<SearchUpdate?>
    func stop()
    func reset()
}
