//
//  WorkoutHeaderView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct WorkoutHeaderView: View {
    let elapsedTime: TimeInterval
    let onCancel: () -> Void
    let onComplete: () -> Void
    
    var body: some View {
        HStack {
            // 경과 시간
            StopwatchView(elapsedTime: elapsedTime)
                .font(.title2)
            
            Spacer()
            
            // 취소 버튼
            Button(action: onCancel) {
                Text("취소")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.red)
                    .cornerRadius(8)
            }
            .padding(.trailing, 8)
            
            // 완료 버튼
            Button(action: onComplete) {
                Text("완료")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .background(Color.blue)
                    .cornerRadius(8)
            }
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

#Preview {
    WorkoutHeaderView(
        elapsedTime: 3665, // 1시간 1분 5초
        onCancel: {},
        onComplete: {}
    )
}
