// ExerciseListView.swift
// 운동 목록 컴포넌트 - 네비게이션 링크 포함
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

// Features 폴더의 ExerciseDetailView 사용
import Foundation
// EmptyState 컴포넌트 import

/* 임시 정의 제거 - 별도 파일로 이동
// 이 뷰에서 사용할 ExerciseDetailView를 간단하게 임시 정의
struct ExerciseDetailView: View {
    let exercise: ExerciseItem
    
    var body: some View {
        Text("운동 상세: \(exercise.name)")
            .navigationTitle(exercise.name)
    }
}
*/

struct ExerciseListView: View {
    let exercises: [ExerciseItem]
    let onAddExercise: () -> Void
    let onRemoveExercise: (ExerciseItem) -> Void
    let onExerciseTapped: (ExerciseItem) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // 헤더 영역
            HStack {
                Text("운동 목록")
                    .font(.headline)
                
                Spacer()
                
                Button(action: onAddExercise) {
                    Label("운동 추가", systemImage: "plus")
                        .font(.subheadline)
                        .foregroundColor(.blue)
                }
            }
            .padding()
            
            if !exercises.isEmpty {
                // 운동 항목 목록
                LazyVStack(spacing: 8) {
                    ForEach(exercises) { exercise in
                        Button {
                            onExerciseTapped(exercise)
                        } label: {
                            ExerciseRowView(exercise: exercise)
                                .background(Color(.systemBackground))
                                .cornerRadius(8)
                                .padding(.horizontal)
                        }
                        .buttonStyle(PlainButtonStyle())
                        .contentShape(Rectangle())
                        .contextMenu {
                            Button(role: .destructive) {
                                onRemoveExercise(exercise)
                            } label: {
                                Label("삭제", systemImage: "trash")
                            }
                        }
                    }
                }
                .padding(.bottom, 8)
            } else {
                // 운동이 없는 경우
                EmptyStateView(
                    icon: "dumbbell.fill",
                    title: "템플릿에 운동이 없습니다",
                    message: "+ 버튼을 눌러 운동을 추가하세요",
                    buttonTitle: "운동 추가하기", 
                    buttonIcon: "plus.circle.fill",
                    action: onAddExercise
                )
                .padding(.vertical, 30)
            }
        }
    }
}

// 템플릿 전용 빈 운동 뷰 - EmptyStateComponents.swift로 이동됨
// struct EmptyTemplateExerciseView: View {
//     let onAddExercise: () -> Void
//     
//     var body: some View {
//         VStack(spacing: 16) {
//             Image(systemName: "dumbbell.fill")
//                 .font(.system(size: 48))
//                 .foregroundColor(.secondary.opacity(0.4))
//             
//             Text("템플릿에 운동이 없습니다")
//                 .font(.headline)
//                 .foregroundColor(.secondary)
//             
//             Text("+ 버튼을 눌러 운동을 추가하세요")
//                 .font(.subheadline)
//                 .foregroundColor(.secondary)
//                 .multilineTextAlignment(.center)
//             
//             Button(action: onAddExercise) {
//                 Label("운동 추가하기", systemImage: "plus.circle.fill")
//                     .font(.headline)
//                     .foregroundColor(.white)
//                     .padding()
//                     .frame(maxWidth: 200)
//                     .background(Color.blue)
//                     .cornerRadius(10)
//             }
//             .padding(.top, 8)
//         }
//         .frame(maxWidth: .infinity)
//         .padding(.vertical, 30)
//     }
// }
