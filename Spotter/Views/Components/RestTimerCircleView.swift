// RestTimerCircleView.swift
// 휴식 타이머를 원형으로 시각화하는 뷰
//  Created by woo on 3/29/25.

import SwiftUI

struct RestTimerCircleView: View {
    let remainingTime: TimeInterval
    let totalTime: TimeInterval
    
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color.gray.opacity(0.2), lineWidth: 3)
            
            Circle()
                .trim(from: 0, to: CGFloat(remainingTime / totalTime))
                .stroke(Color.blue, style: StrokeStyle(lineWidth: 3, lineCap: .round))
                .rotationEffect(.degrees(-90))
                .animation(.linear, value: remainingTime)
        }
    }
}
