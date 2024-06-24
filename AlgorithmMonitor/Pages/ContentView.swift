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
                Section {
                    NavigationLink {
                        SortView<BubbleSort>()
                            .navigationTitle("Bubble Sort")
                    } label: {
                        Text("Bubble Sort")
                    }
                    
                    NavigationLink {
                        SortView<SelectionSort>()
                            .navigationTitle("Selection Sort")
                    } label: {
                        Text("Selection Sort")
                    }
                    
                    NavigationLink {
                        SortView<InsertionSort>()
                            .navigationTitle("Insertion Sort")
                    } label: {
                        Text("Insertion Sort")
                    }
                } header: {
                    Text("Sort")
                }
            }
            .navigationTitle("Algorithm List")
        }
    }
}

#Preview {
    ContentView()
}
