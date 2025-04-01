//
//  ExerciseHeaderView.swift
//  Spotter
//
//  Created by woo on 4/01/25.
//

import SwiftUI
import SwiftData

/// 운동 완료 상태를 나타내는 열거형
enum ExerciseCompletionStatus {
    case idle           // 완료된 세트가 없음
    case active         // 일부 세트만 완료됨
    case done           // 모든 세트 완료됨
    
    // 아이콘 이름
    var icon: String {
        switch self {
        case .idle: return "circle"
        case .active: return "circle.bottomhalf.filled"
        case .done: return "checkmark.circle.fill"
        }
    }
    
    // 아이콘 색상
    var color: Color {
        switch self {
        case .idle: return .gray
        case .active: return .orange
        case .done: return .blue
        }
    }
    
    // 배경 색상
    var backgroundColor: Color {
        switch self {
        case .idle: return Color.gray.opacity(0.08)
        case .active: return Color.orange.opacity(0.12)
        case .done: return Color.blue.opacity(0.12)
        }
    }
    
    // 테두리 색상
    var borderColor: Color {
        switch self {
        case .idle: return Color.gray.opacity(0.15)
        case .active: return Color.orange.opacity(0.2)
        case .done: return Color.blue.opacity(0.2)
        }
    }
}

/// 운동 헤더 컴포넌트 - 통합된 버전
struct ExerciseHeaderView: View {
    // 기본 속성
    let exercise: ExerciseItem
    let isActive: Bool
    let isMinimized: Bool
    let viewModel: ActiveWorkoutViewModel
    
    // 옵션 콜백
    var onMoveUp: (() -> Void)? = nil
    var onMoveDown: (() -> Void)? = nil
    var onToggleMinimized: () -> Void
    
    // 확장 기능 (ActiveExerciseHeaderView에서 통합)
    var completionStatus: ExerciseCompletionStatus = .idle
    var isEditMode: Bool = false
    var onEditModeToggle: (() -> Void)? = nil
    
    @State private var showingRestTimeInfo: Bool = false
    
    var body: some View {
        HStack {
            // 운동 이름과 아이콘을 함께 그룹화
            HStack(spacing: 6) {
                // 최소화/확장 아이콘 - 이름 왼쪽에 위치
                Image(systemName: isMinimized ? "chevron.right.circle.fill" : "chevron.down.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(isMinimized ? .blue : .gray)

                Text(exercise.name.isEmpty ? "운동" : exercise.name)
                    .font(.headline)
                    .foregroundColor(exercise.name.isEmpty ? .secondary : (isMinimized ? .primary.opacity(0.8) : .primary))
                    .italic(exercise.name.isEmpty)
            }
            
            Spacer()
            
            // 메뉴 버튼
            Menu {
                // 메뉴 항목 - 최소화/확장 토글
                Button {
                    onToggleMinimized()
                } label: {
                    Label(isMinimized ? "세트 표시" : "세트 숨기기", 
                          systemImage: isMinimized ? "chevron.down" : "chevron.up")
                }
                
                // 세트 순서 변경 메뉴 항목 (통합)
                if let toggle = onEditModeToggle {
                    Divider()
                    Button(action: toggle) {
                        Label(isEditMode ? "세트 순서 변경 완료" : "세트 순서 변경", 
                              systemImage: isEditMode ? "checkmark.circle" : "arrow.up.arrow.down")
                    }
                }
                
                // 메뉴 항목 - 휴식 시간 설정
                Menu("휴식 시간 설정") {
                    Button("30초") { viewModel.setRestTimeForExercise(exercise, time: 30) }
                    Button("60초") { viewModel.setRestTimeForExercise(exercise, time: 60) }
                    Button("90초") { viewModel.setRestTimeForExercise(exercise, time: 90) }
                    Button("120초") { viewModel.setRestTimeForExercise(exercise, time: 120) }
                    Button("180초") { viewModel.setRestTimeForExercise(exercise, time: 180) }
                }
                
                // 휴식 시간 정보 표시 버튼 (통합)
                Button("휴식 시간 정보") {
                    showingRestTimeInfo = true
                }
                
                // 메뉴 항목 - 이동
                if onMoveUp != nil || onMoveDown != nil {
                    Divider()
                    if let moveUp = onMoveUp {
                        Button(action: moveUp) {
                            Label("위로 이동", systemImage: "arrow.up")
                        }
                    }
                    if let moveDown = onMoveDown {
                        Button(action: moveDown) {
                            Label("아래로 이동", systemImage: "arrow.down")
                        }
                    }
                }
                
                // 메뉴 항목 - 삭제
                Divider()
                Button(role: .destructive) {
                    viewModel.exerciseToDelete = exercise
                } label: {
                    Label("운동 삭제", systemImage: "trash")
                }
            } label: {
                Image(systemName: "ellipsis.circle")
                    .font(.system(size: 20))
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
        .background(completionStatus.backgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(completionStatus.borderColor, lineWidth: 1)
        )
        .cornerRadius(8)
        .contentShape(Rectangle())
        .onTapGesture {
            onToggleMinimized()
        }
        .alert("휴식 시간이란?", isPresented: $showingRestTimeInfo) {
            Button("확인", role: .cancel) { }
        } message: {
            Text("세트 완료 후 표시되는 타이머의 시간입니다. 모든 세트에 동일하게 적용됩니다. 적절한 휴식은 운동 효과를 높이는 데 중요합니다.")
        }
    }
}

// MARK: - Preview
#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        // 기본 상태
        ExerciseHeaderView(
            exercise: ExerciseItem(name: "벤치 프레스", muscleGroup: "가슴"),
            isActive: true,
            isMinimized: false,
            viewModel: ActiveWorkoutViewModel.previewMock(),
            onToggleMinimized: {}
        )
        
        // 최소화 상태
        ExerciseHeaderView(
            exercise: ExerciseItem(name: "스쿼트", muscleGroup: "하체"),
            isActive: false,
            isMinimized: true,
            viewModel: ActiveWorkoutViewModel.previewMock(),
            onToggleMinimized: {}
        )
        
        // 완료 상태
        ExerciseHeaderView(
            exercise: ExerciseItem(name: "데드리프트", muscleGroup: "등"),
            isActive: false,
            isMinimized: false,
            viewModel: ActiveWorkoutViewModel.previewMock(),
            onToggleMinimized: {},
            completionStatus: .done
        )
        
        // 부분 완료 상태
        ExerciseHeaderView(
            exercise: ExerciseItem(name: "랫 풀다운", muscleGroup: "등"),
            isActive: false,
            isMinimized: false,
            viewModel: ActiveWorkoutViewModel.previewMock(),
            onToggleMinimized: {},
            completionStatus: .active,
            isEditMode: true,
            onEditModeToggle: {}
        )
    }
    .background(Color.gray.opacity(0.1))
    .padding()
} 