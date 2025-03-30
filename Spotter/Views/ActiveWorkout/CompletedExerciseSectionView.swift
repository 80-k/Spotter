//
//  CompletedExerciseSectionView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct CompletedExerciseSectionView: View {
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 운동 이름
                Text(exercise.name)
                    .font(.headline)
                
                Spacer()
                
                // 완료 아이콘
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
            }
            
            // 세트 정보 및 통계
            HStack {
                // 세트 수
                InfoLabel(
                    icon: "number.circle.fill",
                    label: "\(viewModel.getSetsForExercise(exercise).count) 세트",
                    color: .blue
                )
                
                Spacer()
                
                // 휴식 시간
                InfoLabel(
                    icon: "timer",
                    label: formatDuration(viewModel.totalRestTimeForExercise(exercise)),
                    color: .orange
                )
                
                Spacer()
                
                // 총 볼륨 (무게 × 횟수)
                InfoLabel(
                    icon: "scalemass.fill",
                    label: String(format: "%.1f kg", viewModel.totalVolumeForExercise(exercise)),
                    color: .purple
                )
            }
            .padding(.top, 4)
        }
        .padding()
        .background(Color.green.opacity(0.05))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.green.opacity(0.2), lineWidth: 1)
        )
    }
    
    // 시간 포맷팅
    private func formatDuration(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        if minutes > 0 {
            return "\(minutes)분 \(remainingSeconds)초"
        } else {
            return "\(remainingSeconds)초"
        }
    }
}

// 정보 라벨 컴포넌트
struct InfoLabel: View {
    let icon: String
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: icon)
                .foregroundColor(color)
                .font(.caption)
            
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
        }
    }
}
