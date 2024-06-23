//
//  BubbleSortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct BubbleSortView: View {
    @StateObject private var viewModel = BubbleSortViewModel()
    @State private var showSettings: Bool = false
    @Environment(\.dismiss) var dismiss
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
                        NumCell(num, index: index)
                            .matchedGeometryEffect(id: num, in: animation)
                    }
                }
                .animation(.easeInOut, value: viewModel.array)
                .frame(maxWidth: .infinity)
                .padding(16)
                .background(
                    RoundedRectangle(cornerRadius: 16)
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
                BubbleSortSettingsView(viewModel: viewModel)
            }
            .presentationDetents([.medium])
        })
        .navigationTitle("Bubble Sort")
    }
}

extension BubbleSortView {
    
    private func cellState(for index: Int) -> CellState {
        if viewModel.confirmedIndices.contains(index) {
            return .confirmed
        } else if viewModel.matchedIndices.contains(index) {
            return .matched
        } else if viewModel.selectedIndices.contains(index) {
            return .selected
        } else {
            return .default
        }
    }
    
    enum CellState {
        case `default`, selected, matched, confirmed
        
        var foregroundColor: Color {
            switch self {
            case .default:
                return .primary
            case .selected:
                return .orange
            case .matched:
                return .white
            case .confirmed:
                return .mint
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default:
                return .white
            case .selected:
                return .white
            case .matched:
                return .orange
            case .confirmed:
                return .white
            }
        }
        
        var lineColor: Color {
            switch self {
            case .default:
                return .primary
            case .selected:
                return .orange
            case .matched:
                return .orange
            case .confirmed:
                return .mint
            }
        }
    }
}

extension BubbleSortView {
    
    private func NumCell(_ num: Int, index: Int) -> some View {
        let state = cellState(for: index)
        let foregroundColor = viewModel.isCompleted ? Color.white : state.foregroundColor
        let backgroundColor = viewModel.isCompleted ? Color.mint : state.backgroundColor
        let lineColor = viewModel.isCompleted ? Color.white : state.lineColor
        let lineWidth: CGFloat = viewModel.isCompleted ? 1.5 : 1
        let fontWeight: Font.Weight = viewModel.isCompleted ? .semibold : .regular
        
        return Text("\(num)")
            .font(.body)
            .fontWeight(fontWeight)
            .padding(.horizontal, 4)
            .foregroundColor(foregroundColor)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(backgroundColor)
                    .overlay {
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(lineColor, lineWidth: lineWidth)
                    }
            )
            .padding(2)
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
                    .disabled(viewModel.isStepping)
                    .opacity(viewModel.isStepping ? 0.5 : 1)
                }
                
                Spacer()
                
                FilledButton(title: "Step Forward", color: .mint) {
                    Task {
                        await viewModel.stepForward()
                    }
                }
                .disabled((viewModel.isSorting || viewModel.isStepping))
                .opacity((viewModel.isSorting || viewModel.isStepping) ? 0.5 : 1)
            }
            
            StrokedButton(title: "Reset", color: .mint) {
                viewModel.resetArray()
            }
        }
    }
}

#Preview {
    NavigationStack {
        BubbleSortView()
    }
}
