//
//  SearchView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct SearchView<T: Searchable>: View {
    @StateObject private var viewModel: SearchViewModel<T>
    @State private var showSettings = false
    @Environment(\.dismiss) var dismiss
    
    init() {
        self._viewModel = StateObject(wrappedValue: SearchViewModel<T>())
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                InfoPanel
                
                StrokedButton(title: "Settings", color: .mint) {
                    viewModel.stopSearch()
                    showSettings.toggle()
                }
                
                SearchChartTabView(viewModel: viewModel)
                
                ControlPanel
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SearchSettingsView<T>(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        }
    }
}

private extension SearchView {
    
    private var InfoPanel: some View {
        VStack {
            InfoRow(label: "Numbers Count:", value: "\(viewModel.confirmedArrayCount)")
            InfoRow(label: "Target Number:", value: "\(viewModel.confirmedTarget)")
            InfoRow(label: "Animation:", value: viewModel.confirmedNeedsAnimation ? "ON" : "OFF")
            InfoRow(label: "Calculations:", value: "\(viewModel.calculationAmount)")
            InfoRow(label: "Sorting Status:", value: viewModel.found ? "Completed" : (viewModel.isSearching ? "Sorting" : "Stopped"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
    }
    
    private var ControlPanel: some View {
        VStack {
            HStack {
                if viewModel.isSearching {
                    FilledButton(title: "Stop", color: .red) {
                        viewModel.stopSearch()
                    }
                } else {
                    FilledButton(title: "Start", color: .blue) {
                        Task { await viewModel.startSearch() }
                    }
                    .disabled(viewModel.found)
                    .opacity(viewModel.found ? 0.5 : 1)
                }
                
                Spacer()
                
                FilledButton(title: "Step Forward", color: .mint) {
                    Task { await viewModel.stepForward() }
                }
                .disabled(viewModel.isSearching || viewModel.found)
                .opacity(viewModel.isSearching || viewModel.found ? 0.5 : 1)
            }
            
            StrokedButton(title: "Reset", color: .mint) {
                viewModel.resetArray()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SortView<BubbleSort>()
    }
}
