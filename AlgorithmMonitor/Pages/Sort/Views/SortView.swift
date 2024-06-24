//
//  SortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct SortView<T: Sortable>: View {
    @StateObject private var viewModel: SortViewModel<T>
    @State private var showSettings = false
    @Environment(\.dismiss) var dismiss
    
    init() {
        self._viewModel = StateObject(wrappedValue: SortViewModel<T>())
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 8) {
                InfoPanel
                
                StrokedButton(title: "Settings", color: .mint) {
                    viewModel.stopSort()
                    showSettings.toggle()
                }
                
                ChartTabView(viewModel: viewModel)
                
                ControlPanel
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showSettings) {
            NavigationStack {
                SortSettingsView<T>(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        }
    }
}

private extension SortView {
    
    private var InfoPanel: some View {
        VStack {
            InfoRow(label: "Numbers Count:", value: "\(viewModel.confirmedArrayCount)")
            InfoRow(label: "Animation:", value: viewModel.confirmedNeedsAnimation ? "ON" : "OFF")
            InfoRow(label: "Calculations:", value: "\(viewModel.calculationAmount)")
            InfoRow(label: "Sorting Status:", value: viewModel.isCompleted ? "Completed" : (viewModel.isSorting ? "Sorting" : "Stopped"))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, 12)
        .padding(.vertical, 8)
        .overlay(RoundedRectangle(cornerRadius: 10).stroke())
    }
    
    private var ControlPanel: some View {
        VStack {
            HStack {
                if viewModel.isSorting {
                    FilledButton(title: "Stop", color: .red) {
                        viewModel.stopSort()
                    }
                } else {
                    FilledButton(title: "Start", color: .blue) {
                        Task { await viewModel.startSort() }
                    }
                    .disabled(viewModel.isStepping || viewModel.isCompleted)
                    .opacity(viewModel.isStepping || viewModel.isCompleted ? 0.5 : 1)
                }
                
                Spacer()
                
                FilledButton(title: "Step Forward", color: .mint) {
                    Task { await viewModel.stepForward() }
                }
                .disabled(viewModel.isSorting || viewModel.isStepping || viewModel.isCompleted)
                .opacity(viewModel.isSorting || viewModel.isStepping || viewModel.isCompleted ? 0.5 : 1)
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
