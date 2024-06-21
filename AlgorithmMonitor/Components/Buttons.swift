//
//  BubbleSortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct StrokedButton: View {
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .stroke(color)
                .frame(height: 40)
                .overlay {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(color)
                }
        }
    }
}

struct FilledButton: View {
    var title: String
    var color: Color
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            RoundedRectangle(cornerRadius: 8)
                .fill(color)
                .frame(height: 40)
                .overlay {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(Color.white)
                }
        }
    }
}

#Preview {
    NavigationStack {
        BubbleSortView()
    }
}
