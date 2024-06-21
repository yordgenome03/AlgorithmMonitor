//
//  BubbleSortTests.swift
//  AlgorithmMonitorTests
//
//  Created by yotahara on 2024/06/21.
//

import XCTest
@testable import AlgorithmMonitor

final class BubbleSortTests: XCTestCase {
    
    func testSortWithoutAnimation() async {
        let array = [5, 3, 8, 4, 2]
        let bubbleSort = BubbleSort(array: array, needsAnimation: false)
        
        var updates: [BubbleSortUpdate] = []
        
        for await update in bubbleSort.sort() {
            if let update = update {
                updates.append(update)
            }
        }
        XCTAssertEqual(updates.count, 1)
        XCTAssertTrue(updates.first?.isCompleted == true)
        XCTAssertEqual(updates.first?.array, array.sorted())
        XCTAssertTrue(updates.last?.isCompleted == true)
        XCTAssertEqual(updates.last?.array, array.sorted())
    }
    
    func testSortWithAnimation() async {
        let array = [5, 3, 8, 4, 2]
        let bubbleSort = BubbleSort(array: array, needsAnimation: true)
        
        var updates: [BubbleSortUpdate] = []
        
        for await update in bubbleSort.sort() {
            if let update = update {
                updates.append(update)
            }
        }
        XCTAssertEqual(updates.count, 21)
        
        XCTAssertEqual(updates.first?.array, [5, 3, 8, 4, 2])
        XCTAssertEqual(updates.first?.activeIndices?.0, 0)
        XCTAssertEqual(updates.first?.activeIndices?.1, 1)

        XCTAssertEqual(updates[1].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[1].activeIndices?.0, 0)
        XCTAssertEqual(updates[1].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[2].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[2].activeIndices?.0, 1)
        XCTAssertEqual(updates[2].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[3].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[3].activeIndices?.0, 2)
        XCTAssertEqual(updates[3].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[4].array, [3, 5, 4, 8, 2])
        XCTAssertEqual(updates[4].activeIndices?.0, 2)
        XCTAssertEqual(updates[4].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[5].array, [3, 5, 4, 8, 2])
        XCTAssertEqual(updates[5].activeIndices?.0, 3)
        XCTAssertEqual(updates[5].activeIndices?.1, 4)
        
        XCTAssertEqual(updates[6].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[6].activeIndices?.0, 3)
        XCTAssertEqual(updates[6].activeIndices?.1, 4)
        
        XCTAssertEqual(updates[7].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[7].activeIndices?.0, 0)
        XCTAssertEqual(updates[7].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[8].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[8].activeIndices?.0, 0)
        XCTAssertEqual(updates[8].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[9].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[9].activeIndices?.0, 1)
        XCTAssertEqual(updates[9].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[10].array, [3, 4, 5, 2, 8])
        XCTAssertEqual(updates[10].activeIndices?.0, 1)
        XCTAssertEqual(updates[10].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[11].array, [3, 4, 5, 2, 8])
        XCTAssertEqual(updates[11].activeIndices?.0, 2)
        XCTAssertEqual(updates[11].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[12].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[12].activeIndices?.0, 2)
        XCTAssertEqual(updates[12].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[13].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[13].activeIndices?.0, 0)
        XCTAssertEqual(updates[13].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[14].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[14].activeIndices?.0, 0)
        XCTAssertEqual(updates[14].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[15].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[15].activeIndices?.0, 1)
        XCTAssertEqual(updates[15].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[16].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[16].activeIndices?.0, 1)
        XCTAssertEqual(updates[16].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[17].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[17].activeIndices?.0, 0)
        XCTAssertEqual(updates[17].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[18].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[18].activeIndices?.0, 0)
        XCTAssertEqual(updates[18].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[19].array, [2, 3, 4, 5, 8])
        XCTAssertEqual(updates[19].activeIndices?.0, 0)
        XCTAssertEqual(updates[19].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[20].array, [2, 3, 4, 5, 8])
        XCTAssertEqual(updates[20].activeIndices?.0, nil)
        XCTAssertEqual(updates[20].activeIndices?.1, nil)
        XCTAssertTrue(updates[20].isCompleted)
        
        XCTAssertTrue(updates.last?.isCompleted == true)
        XCTAssertEqual(updates.last?.array, array.sorted())
    }
    
    func testStepForward() async {
        let array = [5, 3, 8, 4, 2]
        let bubbleSort = BubbleSort(array: array, needsAnimation: false)
        
        var updates: [BubbleSortUpdate] = []
        
        for _ in 0..<40 {
            for await update in bubbleSort.stepForward() {
                if let update = update {
                    updates.append(update)
                    if update.isCompleted {
                        break
                    }
                }
            }
        }
        XCTAssertEqual(updates.count, 21)
        
        XCTAssertEqual(updates.first?.array, [5, 3, 8, 4, 2])
        XCTAssertEqual(updates.first?.activeIndices?.0, 0)
        XCTAssertEqual(updates.first?.activeIndices?.1, 1)
        
        XCTAssertEqual(updates[1].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[1].activeIndices?.0, 0)
        XCTAssertEqual(updates[1].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[2].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[2].activeIndices?.0, 1)
        XCTAssertEqual(updates[2].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[3].array, [3, 5, 8, 4, 2])
        XCTAssertEqual(updates[3].activeIndices?.0, 2)
        XCTAssertEqual(updates[3].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[4].array, [3, 5, 4, 8, 2])
        XCTAssertEqual(updates[4].activeIndices?.0, 2)
        XCTAssertEqual(updates[4].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[5].array, [3, 5, 4, 8, 2])
        XCTAssertEqual(updates[5].activeIndices?.0, 3)
        XCTAssertEqual(updates[5].activeIndices?.1, 4)
        
        XCTAssertEqual(updates[6].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[6].activeIndices?.0, 3)
        XCTAssertEqual(updates[6].activeIndices?.1, 4)
        
        XCTAssertEqual(updates[7].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[7].activeIndices?.0, 0)
        XCTAssertEqual(updates[7].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[8].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[8].activeIndices?.0, 0)
        XCTAssertEqual(updates[8].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[9].array, [3, 5, 4, 2, 8])
        XCTAssertEqual(updates[9].activeIndices?.0, 1)
        XCTAssertEqual(updates[9].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[10].array, [3, 4, 5, 2, 8])
        XCTAssertEqual(updates[10].activeIndices?.0, 1)
        XCTAssertEqual(updates[10].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[11].array, [3, 4, 5, 2, 8])
        XCTAssertEqual(updates[11].activeIndices?.0, 2)
        XCTAssertEqual(updates[11].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[12].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[12].activeIndices?.0, 2)
        XCTAssertEqual(updates[12].activeIndices?.1, 3)
        
        XCTAssertEqual(updates[13].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[13].activeIndices?.0, 0)
        XCTAssertEqual(updates[13].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[14].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[14].activeIndices?.0, 0)
        XCTAssertEqual(updates[14].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[15].array, [3, 4, 2, 5, 8])
        XCTAssertEqual(updates[15].activeIndices?.0, 1)
        XCTAssertEqual(updates[15].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[16].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[16].activeIndices?.0, 1)
        XCTAssertEqual(updates[16].activeIndices?.1, 2)
        
        XCTAssertEqual(updates[17].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[17].activeIndices?.0, 0)
        XCTAssertEqual(updates[17].activeIndices?.1, 0)
        
        XCTAssertEqual(updates[18].array, [3, 2, 4, 5, 8])
        XCTAssertEqual(updates[18].activeIndices?.0, 0)
        XCTAssertEqual(updates[18].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[19].array, [2, 3, 4, 5, 8])
        XCTAssertEqual(updates[19].activeIndices?.0, 0)
        XCTAssertEqual(updates[19].activeIndices?.1, 1)
        
        XCTAssertEqual(updates[20].array, [2, 3, 4, 5, 8])
        XCTAssertEqual(updates[20].activeIndices?.0, nil)
        XCTAssertEqual(updates[20].activeIndices?.1, nil)
        XCTAssertTrue(updates[20].isCompleted)
        
        XCTAssertTrue(updates.last?.isCompleted == true)
        XCTAssertEqual(updates.last?.array, array.sorted())
    }
}
