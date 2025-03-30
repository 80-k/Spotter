// StartWorkoutButtonView.swift
// 운동 시작 버튼 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI

struct StartWorkoutButtonView: View {
    let isDisabled: Bool
    let onStartWorkout: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            Divider()
            
            Button(action: onStartWorkout) {
                HStack {
                    Image(systemName: "play.circle.fill")
                        .font(.system(size: 20))
                        .padding(.trailing, 4)
                    
                    Text("운동 시작")
                        .font(.headline)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(isDisabled ? Color.gray : Color.blue)
                .cornerRadius(10)
            }
            .disabled(isDisabled)
            .padding(.horizontal)
            .padding(.bottom, 8)
        }
        .background(Color(.systemBackground))
    }
}
