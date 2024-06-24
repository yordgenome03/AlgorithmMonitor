//
//  ChartTabView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

enum DisplayStyle: String, CustomStringConvertible, CaseIterable {
    case capsules = "Capsules"
    case bars = "Bars"
    
    var description: String { self.rawValue }
}

struct ChartTabView<T: Sortable>: View {
    @StateObject private var viewModel: SortViewModel<T>
    @State private var selection: DisplayStyle = .capsules
    @Namespace var animation
    
    init(viewModel: SortViewModel<T>) {
        self._viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        VStack {
            DisplayStylePicker
            
            TabView(selection: $selection) {
                CapsuleChart
                    .edgesIgnoringSafeArea(.bottom)
                    .tag(DisplayStyle.capsules)
                
                BarChart
                    .edgesIgnoringSafeArea(.bottom)
                    .tag(DisplayStyle.bars)
            }
            .frame(height: 248)
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
        .padding(16)
    }
    
    private var BarChart: some View {
        GeometryReader { geometry in
            HStack(alignment: .bottom, spacing: 0) {
                ForEach(Array(viewModel.array.enumerated()), id: \.offset) { index, num in
                    Bar(num: num, 
                        index: index,
                        width: geometry.size.width / CGFloat(viewModel.array.count),
                        height: geometry.size.height / CGFloat(viewModel.array.count) * CGFloat(num))
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.isCompleted ? .mint : .clear, lineWidth: 2)
                )
        )
        .padding(1)
    }
    
    private var CapsuleChart: some View {
        ScrollView {
            FlowLayout(alignment: .leading) {
                ForEach(Array(viewModel.array.enumerated()), id: \.offset) { index, num in
                    NumCapsule(num: num, index: index)
                        .matchedGeometryEffect(id: num, in: animation)
                }
            }
            .padding(.vertical, 24)
        }
        .animation(.easeInOut, value: viewModel.array)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.systemGroupedBackground))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(viewModel.isCompleted ? .mint : .clear, lineWidth: 2)
                )
        )
        .padding(1)
    }
    
    private func NumCapsule(num: Int, index: Int) -> some View {
        let state = cellState(for: index)
        let foregroundColor = viewModel.isCompleted ? .white : state.foregroundColor
        let backgroundColor = viewModel.isCompleted ? .mint : state.backgroundColor
        let lineColor = viewModel.isCompleted ? .white : state.lineColor
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
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(lineColor, lineWidth: lineWidth))
            )
            .padding(2)
    }
    
    private func Bar(num: Int, index: Int, width: CGFloat, height: CGFloat) -> some View {
        let state = cellState(for: index)
        let foregroundColor = viewModel.isCompleted ? .white : state.foregroundColor
        let backgroundColor = viewModel.isCompleted ? .mint : state.backgroundColor
        
        return Rectangle()
            .fill(backgroundColor)
            .frame(width: width, height: height)
            .overlay(Rectangle().stroke(foregroundColor, lineWidth: 0.5))
    }
    
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
    
    private var DisplayStylePicker: some View {
        Picker("", selection: $selection) {
            ForEach(DisplayStyle.allCases, id: \.description) {
                Text($0.description).tag($0)
            }
        }
        .pickerStyle(SegmentedPickerStyle())
        .frame(maxWidth: .infinity, alignment: .center)
    }
    
    enum CellState {
        case `default`, selected, matched, confirmed
        
        var foregroundColor: Color {
            switch self {
            case .default: return .primary
            case .selected: return .yellow
            case .matched: return .white
            case .confirmed: return .white
            }
        }
        
        var backgroundColor: Color {
            switch self {
            case .default: return .white
            case .selected: return .white
            case .matched: return .yellow
            case .confirmed: return .mint
            }
        }
        
        var lineColor: Color {
            switch self {
            case .default: return .primary
            case .selected: return .yellow
            case .matched: return .white
            case .confirmed: return .white
            }
        }
    }
}

#Preview {
    NavigationStack {
        ChartTabView<BubbleSort>(viewModel: .init())
    }
}
