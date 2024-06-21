//
//  BubbleSortView.swift
//  AlgorithmMonitor
//
//  Created by yotahara on 2024/06/21.
//

import SwiftUI

struct InfoRow: View {
    var label: String
    var value: String
    
    var body: some View {
        HStack {
            Image(systemName: "square.fill")
                .font(.subheadline)
            
            Text(label)
                .font(.subheadline)
            
            Text(value)
                .font(.title3.bold())
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

struct SettingRow<Content: View>: View {
    var label: String
    var value: String
    var content: Content
    
    init(label: String, value: String, @ViewBuilder content: () -> Content) {
        self.label = label
        self.value = value
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text(label)
                .font(.subheadline)
                .foregroundStyle(Color(.systemGray))
            
            HStack {
                Text(value)
                    .font(.callout)
                content
                    .frame(maxWidth: .infinity)
            }
        }
    }
}
//
//#Preview {
//    NavigationStack {
//        BubbleSortView()
//    }
//}
