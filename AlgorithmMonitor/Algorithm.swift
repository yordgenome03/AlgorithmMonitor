//
//  Algorithm.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import Foundation

class Algorithm {
    // 単純交換法（バブルソート）：昇順
    static func bubbleSort<T: Comparable>(_ array: inout [T]) async -> [T] {
            var sortedArray = array
            let n = array.count
            // リストの先頭から値を比較していき昇順に並べる
            // 一番内側のループが終了した時、最大値がリストの終端に移動する
            for i in 0..<n {
                // 次のループではリストの要素数を一つ減らして比較
                for j in 0..<(n-i-1) {
                    try? await Task.sleep(nanoseconds: 5_000_000)
                    if sortedArray[j] > sortedArray[j+1] {
                        sortedArray.swapAt(j, j+1)
                    }
                }
            }
            return sortedArray
        }
}
