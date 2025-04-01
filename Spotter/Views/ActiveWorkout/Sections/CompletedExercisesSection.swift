// CompletedExercisesSection.swift
// 완료된 운동 목록 섹션 컴포넌트
// Created by woo on 3/30/25.

import SwiftUI

struct CompletedExercisesSection: View {
    var viewModel: ActiveWorkoutViewModel
    
    var body: some View {
        if !viewModel.completedExercises.isEmpty {
            // 이름 변경된 컴포넌트 사용
            WorkoutSectionHeaderView(
                title: "완료된 운동",
                icon: "checkmark.circle.fill",
                color: .green
            )
            .padding(.horizontal)
            .padding(.top, 8)
            
            LazyVStack(spacing: 12) {
                ForEach(viewModel.completedExercises) { exercise in
                    // 이름 변경: CompletedExerciseSectionView → CompletedExerciseItemView
                    CompletedExerciseItemView(
                        viewModel: viewModel,
                        exercise: exercise
                    )
                    .padding(.horizontal)
                }
            }
        }
    }
}

// 이름 변경: CompletedExerciseSectionView → CompletedExerciseItemView
struct CompletedExerciseItemView: View {
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                // 운동 이름
                Text(exercise.name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Spacer()
                
                // 세트 추가 버튼
                Button(action: {
                    viewModel.addSetToCompletedExercise(exercise)
                }) {
                    HStack(spacing: 4) {
                        Text("세트 추가")
                            .font(.caption)
                            .foregroundColor(.green)
                        
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(.green)
                    }
                    .padding(.vertical, 4)
                    .padding(.horizontal, 8)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                    )
                }
                .buttonStyle(PlainButtonStyle())
                
                // 운동 재시작 버튼 (드롭다운 메뉴로 변경)
                Menu {
                    Button(action: {
                        // 기존 재시작 기능 (모든 세트를 미완료 상태로 변경)
                        viewModel.reactivateExercise(exercise)
                    }) {
                        Label("전체 재시작", systemImage: "arrow.counterclockwise")
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                        .foregroundColor(.secondary)
                        .padding(8)
                }
            }
            
            // 세트 정보 및 통계
            HStack {
                // 세트 수
                // 이름 변경: InfoLabel → ExerciseInfoLabel
                ExerciseInfoLabel(
                    icon: "number.circle.fill",
                    label: "\(viewModel.getSetsForExercise(exercise).count) 세트",
                    color: .blue
                )
                
                Spacer()
                
                // 휴식 시간
                ExerciseInfoLabel(
                    icon: "timer",
                    label: formatDuration(viewModel.totalRestTimeForExercise(exercise)),
                    color: .orange
                )
                
                Spacer()
                
                // 총 볼륨 (무게 × 횟수)
                ExerciseInfoLabel(
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

// 정보 라벨 컴포넌트 - 이름 변경
struct ExerciseInfoLabel: View {
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
