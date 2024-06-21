//
//  BubbleSortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct BubbleSortSettingsView: View {
    @StateObject private var viewModel: BubbleSortViewModel
    @Environment(\.dismiss) var dismiss
    
    init(viewModel: BubbleSortViewModel) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            SettingRow(label: "Numbers Count:",
                       value: "\(viewModel.arrayCount)",
                       content: {
                Stepper("", value: $viewModel.arrayCount, in: 1...100, step: 5)
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
        BubbleSortSettingsView(viewModel: .init())
    }
}
