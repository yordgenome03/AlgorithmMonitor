//
//  SortSettingsView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct SortSettingsView<T: Sortable>: View {
    @StateObject private var viewModel: SortViewModel<T>
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: SortViewModel<T>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            SettingRow(label: "Numbers Count:",
                       value: "\(viewModel.arrayCount)",
                       content: {
                Stepper("", value: $viewModel.arrayCount, in: 5...100, step: 5)
                    .padding(.vertical)
            })
            
            SettingRow(label: "Animation", value: viewModel.needsAnimation ? "ON" : "OFF") {
                Toggle("", isOn: $viewModel.needsAnimation)
                    .padding(.vertical)
            }
            
            FilledButton(title: "Apply", color: .mint) {
                viewModel.applySettings()
                dismiss()
            }
        }
        .padding()
        .navigationTitle("Settings")
    }
}

#Preview {
    NavigationStack {
        SortSettingsView<BubbleSort>(viewModel: .init())
    }
}
