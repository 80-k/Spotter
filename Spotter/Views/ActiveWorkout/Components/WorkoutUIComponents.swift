// WorkoutUIComponents.swift
// 운동 UI 관련 공통 컴포넌트 모음
// Created by woo on 3/30/25.

import SwiftUI

// 세션 헤더 - 시간 및 제어 버튼
// WorkoutHeaderView → ActiveWorkoutHeaderView 이름 변경
struct ActiveWorkoutHeaderView: View {
    let elapsedTime: TimeInterval
    let onCancel: () -> Void
    let onComplete: () -> Void
    let isCompleteEnabled: Bool
    
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
                    .background(isCompleteEnabled ? Color.blue : Color.gray)
                    .cornerRadius(8)
            }
            .disabled(!isCompleteEnabled)
        }
        .padding()
        .background(Color.secondary.opacity(0.1))
    }
}

// 운동 완료 상태 엔음
// 운동의 세트 완료 상태를 표시하기 위한 엔음
enum ExerciseCompletionStatus {
    case notCompleted      // 완료된 세트 없음
    case partiallyCompleted // 일부 세트만 완료됨
    case completed         // 모든 세트 완료됨
    
    // 아이콘 이름
    var icon: String {
        switch self {
        case .notCompleted: return "circle"
        case .partiallyCompleted: return "circle.bottomhalf.filled"
        case .completed: return "checkmark.circle.fill"
        }
    }
    
    // 아이콘 색상
    var color: Color {
        switch self {
        case .notCompleted: return .gray
        case .partiallyCompleted: return .orange
        case .completed: return .green
        }
    }
}

// 운동 세션 헤더
// WorkoutExerciseHeader → ActiveExerciseHeaderView 이름 변경
struct ActiveExerciseHeaderView: View {
    let exerciseName: String
    var completionStatus: ExerciseCompletionStatus = .notCompleted
    let onRestTimeChange: (TimeInterval) -> Void
    let onDelete: () -> Void
    
    @State private var showingRestTimeInfo: Bool = false
    
    var body: some View {
        HStack {
            // 운동 이름 표시
            HStack(spacing: 6) {
                // 완료 상태 아이콘
                Image(systemName: completionStatus.icon)
                    .foregroundColor(completionStatus.color)
                    .font(.system(size: 16))
                
                if exerciseName.isEmpty {
                    Text("운동")
                        .font(.headline)
                        .italic()
                        .foregroundColor(.secondary)
                } else {
                    Text(exerciseName)
                        .font(.headline)
                }
            }
            
            Spacer()
            
            // 컨텍스트 메뉴 버튼 추가
            Menu {
                // 휴식 시간 변경 메뉴
                Menu("휴식 시간 설정") {
                    Button("30초") { onRestTimeChange(30) }
                    Button("60초") { onRestTimeChange(60) }
                    Button("90초") { onRestTimeChange(90) }
                    Button("120초") { onRestTimeChange(120) }
                    Button("180초") { onRestTimeChange(180) }
                }
                
                // 휴식 시간 정보 표시 버튼
                Button("휴식 시간 정보") {
                    showingRestTimeInfo = true
                }
                
                Divider()
                
                // 운동 삭제 버튼
                Button(role: .destructive, action: onDelete) {
                    Label("운동 삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .foregroundColor(.gray)
                    .padding(8)
            }
        }
        .padding(.horizontal)
        .padding(.top, 12)
        .padding(.bottom, 8)
        .alert("휴식 시간이란?", isPresented: $showingRestTimeInfo) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("세트 완료 후 표시되는 타이머의 시간입니다. 모든 세트에 동일하게 적용됩니다. 적절한 휴식은 운동 효과를 높이는 데 중요합니다.")
        }
    }
}

// 섹션 헤더 컴포넌트
// SectionHeader → WorkoutSectionHeaderView 이름 변경
struct WorkoutSectionHeaderView: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}

// 운동 추가 버튼
// AddExerciseButton → WorkoutAddExerciseButton 이름 변경
struct WorkoutAddExerciseButton: View {
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .foregroundColor(.blue)
                Text("운동 추가")
                    .font(.headline)
                    .foregroundColor(.blue)
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.blue.opacity(0.1))
            .cornerRadius(8)
        }
    }
}
