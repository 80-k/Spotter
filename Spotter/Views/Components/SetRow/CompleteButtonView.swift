//
//  CompleteButtonView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct CompleteButtonView: View {
    let isCompleted: Bool
    let isDisabled: Bool
    var onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            if isCompleted {
                completedButton
            } else {
                incompleteButton
            }
        }
        .disabled(isDisabled && !isCompleted)
    }
    
    // 완료된 상태 버튼
    private var completedButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("완료")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .cornerRadius(5)
    }
    
    // 미완료 상태 버튼
    private var incompleteButton: some View {
        Text("완료")
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(isDisabled ? Color.gray : Color.blue)
            .cornerRadius(5)
    }
}

#Preview {
    VStack(spacing: 20) {
        // 완료 상태
        CompleteButtonView(
            isCompleted: true,
            isDisabled: false,
            onTap: {}
        )
        
        // 미완료 상태
        CompleteButtonView(
            isCompleted: false,
            isDisabled: false,
            onTap: {}
        )
        
        // 비활성화 상태
        CompleteButtonView(
            isCompleted: false,
            isDisabled: true,
            onTap: {}
        )
    }
}
