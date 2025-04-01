// ActiveExerciseSection.swift
// 현재 진행 중인 운동 섹션 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

// 현재 진행 중인 운동을 표시하는 섹션
struct ActiveExerciseSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if let activeExercise = viewModel.currentActiveExercise {
                VStack(alignment: .leading, spacing: 8) {
                    // 헤더 영역
                    HStack {
                        Image(systemName: "figure.strengthtraining.traditional")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(SpotColor.primary)
                        Text("현재 진행 중")
                            .font(.headline)
                            .fontWeight(.semibold)
                            .foregroundColor(SpotColor.primary)
                        
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                    
                    // 분리된 운동 뷰 컴포넌트 사용
                    ActiveWorkoutExerciseView(
                        viewModel: viewModel,
                        exercise: activeExercise,
                        isActive: true
                    )
                    .padding(.horizontal, 4)
                }
                .padding(.bottom, 12)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(Color(.secondarySystemGroupedBackground))
                )
                .padding(.horizontal)
                .transition(.opacity.combined(with: .scale))
            }
        }
    }
}
