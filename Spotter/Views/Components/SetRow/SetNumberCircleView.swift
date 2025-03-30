//
//  SetNumberCircleView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct SetNumberCircleView: View {
    let number: Int
    let isCompleted: Bool
    
    var body: some View {
        ZStack {
            Circle()
                .fill(isCompleted ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Text("\(number)")
                .font(.headline)
                .foregroundColor(isCompleted ? .green : .blue)
        }
    }
}

#Preview {
    HStack {
        SetNumberCircleView(number: 1, isCompleted: false)
        SetNumberCircleView(number: 2, isCompleted: true)
    }
    .padding()
}
