// ExerciseControlButtonsSection.swift
// 운동 컨트롤 버튼 섹션 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

// 운동 컨트롤 버튼 섹션 컴포넌트
struct ExerciseControlButtonsSection: View {
    var isEditMode: Bool
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    var onEditModeToggle: () -> Void
    var onSetsUpdate: () -> Void
    @Binding var sets: [WorkoutSet]
    
    var body: some View {
        // 세트 추가 또는 편집 완료 버튼
        if !isEditMode {
            Button(action: {
                print("세트 추가 버튼 클릭됨 - 운동: \(exercise.name)")
                
                // 세트 추가
                let newSet = viewModel.addSet(for: exercise)
                print("새 세트 ID: \(newSet.id)")
                
                // 즉시 세트 배열에 추가 (UI 즉시 갱신)
                sets.append(newSet)
                
                // 세트 목록 강제 새로고침 (백그라운드에서 다시 로드)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    onSetsUpdate()
                }
            }) {
                HStack {
                    Spacer()
                    Image(systemName: "plus")
                        .font(.system(size: 12, weight: .semibold))
                    Text("세트 추가")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.vertical, 10)
                .foregroundColor(SpotColor.primary)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(SpotColor.primary.opacity(0.08))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 12)
        } else {
            // 편집 모드일 때는 완료 버튼 표시
            Button(action: onEditModeToggle) {
                HStack {
                    Spacer()
                    Image(systemName: "checkmark")
                        .font(.system(size: 12, weight: .semibold))
                    Text("순서 변경 완료")
                        .font(.subheadline)
                        .fontWeight(.medium)
                    Spacer()
                }
                .padding(.vertical, 10)
                .foregroundColor(SpotColor.success)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .fill(SpotColor.success.opacity(0.08))
                )
            }
            .buttonStyle(PlainButtonStyle())
            .padding(.horizontal, 12)
            .padding(.top, 4)
            .padding(.bottom, 12)
        }
    }
}
