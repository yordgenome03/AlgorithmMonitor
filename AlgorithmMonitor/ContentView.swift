//
//  ContentView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List {
                NavigationLink {
                    BubbleSortView()
                } label: {
                    Text("Bubble Sort")
                }
                
                NavigationLink {
                    SelectionSortView()
                } label: {
                    Text("Selection Sort")
                }
            }
            .navigationTitle("Algorithm")
        }
    }
}

#Preview {
    ContentView()
}
