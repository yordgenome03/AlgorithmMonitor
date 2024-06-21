//
//  SelectionSortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct SelectionSortView: View {
    @StateObject private var viewModel = SelectionSortViewModel()
    @State private var showSettings: Bool = false
    @Namespace var animation

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack {
                InfoPanel
                
                StrokedButton(title: "Settings", color: .mint) {
                    viewModel.stopSort()
                    showSettings.toggle()
                }
                
                FlowLayout(alignment: .leading) {
                    ForEach(Array(viewModel.array.enumerated()), id: \.offset) { index, num in
                        NumCell(num, isActive: isIndexActive(index))
                            .matchedGeometryEffect(id: num, in: animation)
                    }
                }
                .animation(.easeInOut, value: viewModel.array)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(                    RoundedRectangle(cornerRadius: 16)
                    .fill(viewModel.isCompleted ? Color.mint : Color(.systemGray6))
                )
                .padding(.horizontal, 16)
                .padding(.vertical, 40)
                
                ControlPanel
                
                Spacer()
            }
            .padding(.horizontal, 16)
        }
        .sheet(isPresented: $showSettings, content: {
            NavigationStack {
                SelectionSortSettingsView(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        })
        .navigationTitle("Selection Sort")
    }
    
    private func isIndexActive(_ index: Int) -> Bool {
        viewModel.activeIndices?.0 == index ||
        viewModel.activeIndices?.1 == index ||
        viewModel.activeIndices?.2 == index
    }
}

extension SelectionSortView {
    
    private func NumCell(_ num: Int, isActive: Bool) -> some View {
        let activeColor = viewModel.isCompleted ? Color.white: Color.red
        let inactiveColor = viewModel.isCompleted ? Color.white: Color.primary
        let lineWidth: CGFloat = viewModel.isCompleted ? 1.5 : 1
        let fontWeight: Font.Weight = viewModel.isCompleted ? .semibold : .regular
        
        return Text("\(num)")
            .font(.body)
            .fontWeight(fontWeight)
            .padding(.horizontal, 4)
            .foregroundColor(isActive ? activeColor : inactiveColor)
            .overlay {
                RoundedRectangle(cornerRadius: 8)
                    .stroke(isActive ? activeColor : inactiveColor, lineWidth: lineWidth)
            }
            .padding(2)
    }
    
    private var StartButton: some View {
        Button {
            Task {
                await viewModel.startSort()
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.mint)
                .frame(height: 40)
                .overlay {
                    Text("Start")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
        }
    }
    
    private var StopButton: some View {
        Button {
            viewModel.stopSort()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.red)
                .frame(height: 40)
                .overlay {
                    Text("Stop")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
        }
    }
    
    private var ResetButton: some View {
        Button {
            viewModel.resetArray()
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .stroke(Color.mint)
                .frame(height: 40)
                .overlay {
                    Text("Reset")
                        .font(.headline)
                        .foregroundStyle(Color.mint)
                }
        }
    }
    
    private var StepForwardButton: some View {
        Button {
            Task {
                await viewModel.stepForward()
            }
        } label: {
            RoundedRectangle(cornerRadius: 8)
                .fill(Color.blue)
                .frame(height: 40)
                .overlay {
                    Text("Step Forward")
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
        }
    }
    
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
                        Task {
                            await viewModel.startSort()
                        }
                    }
                }
                
                Spacer()
                
                FilledButton(title: "Step Forward", color: .mint) {
                    Task {
                        await viewModel.stepForward()
                    }
                }
                .disabled(viewModel.isSorting)
                .opacity(viewModel.isSorting ? 0.5 : 1)
            }
            
            StrokedButton(title: "Reset", color: .mint) {
                viewModel.resetArray()
            }
        }
    }
}

#Preview {
    NavigationStack {
        SelectionSortView()
    }
}
