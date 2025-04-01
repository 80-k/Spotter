// ExerciseSetRowView.swift
// 운동 세트 행 컴포넌트
//  Created by woo on 3/29/25.

import SwiftUI
import Combine

struct ExerciseSetRowView: View {
    var set: WorkoutSet
    let setNumber: Int
    
    var onWeightChanged: (Double) -> Void
    var onRepsChanged: (Int) -> Void
    var onCompleteToggle: () -> Void
    var disableCompleteButton: Bool  // 완료 버튼만 비활성화하는 플래그
    
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isRepsFocused: Bool
    
    @State private var weightString: String = ""
    @State private var repsString: String = ""
    @State private var showWeightWarning: Bool = false
    @State private var showRepsWarning: Bool = false
    
    init(set: WorkoutSet, setNumber: Int, onWeightChanged: @escaping (Double) -> Void, onRepsChanged: @escaping (Int) -> Void, onCompleteToggle: @escaping () -> Void, disableCompleteButton: Bool = false) {
        self.set = set
        self.setNumber = setNumber
        self.onWeightChanged = onWeightChanged
        self.onRepsChanged = onRepsChanged
        self.onCompleteToggle = onCompleteToggle
        self.disableCompleteButton = disableCompleteButton
        
        // 무게값 표시 방식 변경 - 정수면 정수로, 소수점 있으면 소수점 포함 표시
        let weight = set.weight
        let isInteger = weight.truncatingRemainder(dividingBy: 1) == 0
        self._weightString = State(initialValue: weight > 0 ? (isInteger ? "\(Int(weight))" : String(format: "%.1f", weight)) : "")
        self._repsString = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
    }
    
    var body: some View {
        setRow
            .padding(8)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(set.isCompleted ? SpotColor.completedSet.opacity(0.05) : Color.clear)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(set.isCompleted ? SpotColor.success.opacity(0.15) : Color.clear, lineWidth: 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                // 입력 필드 외 영역 터치 시 키보드 내리기
                isWeightFocused = false
                isRepsFocused = false
            }
            // NotificationCenter 리스너 등록 - 'ClearRepsField' 알림 수신
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("ClearRepsField"))) { _ in
                repsString = ""
                onRepsChanged(0)
            }
            // 키보드 툴바 추가
            .withKeyboardToolbar(
                weightFocused: Binding<Bool>(
                    get: { isWeightFocused },
                    set: { isWeightFocused = $0 }
                ),
                repsFocused: Binding<Bool>(
                    get: { isRepsFocused },
                    set: { isRepsFocused = $0 }
                ),
                weightString: weightString,
                onWeightChanged: onWeightChanged
            )
    }
    
    // 기본 세트 행 - 레이아웃 개선
    private var setRow: some View {
        HStack(spacing: 8) { // 좌우 간격 축소
            // 세트 번호
            SetNumberCircle(setNumber: setNumber, isCompleted: set.isCompleted)
                .frame(width: 32) // 크기 약간 축소
            
            // 무게 및 횟수 입력 영역 - 너비 조절
            HStack(spacing: 10) { // 간격 약간 넓힘
                // 무게 입력 영역
                WeightInputField(
                    weight: set.weight,
                    isCompleted: set.isCompleted,
                    isFocused: Binding<Bool>(
                        get: { isWeightFocused },
                        set: { isWeightFocused = $0 }
                    ),
                    weightString: $weightString,
                    showWarning: $showWeightWarning,
                    disableCompleteButton: disableCompleteButton,
                    onWeightChanged: onWeightChanged,
                    onCompleteToggle: onCompleteToggle
                )
                .frame(width: 85) // 크기 조절
                
                // 횟수 입력 영역
                RepsInputField(
                    reps: set.reps,
                    isCompleted: set.isCompleted,
                    isFocused: Binding<Bool>(
                        get: { isRepsFocused },
                        set: { isRepsFocused = $0 }
                    ),
                    repsString: $repsString,
                    showWarning: $showRepsWarning,
                    disableCompleteButton: disableCompleteButton,
                    onRepsChanged: onRepsChanged,
                    onCompleteToggle: onCompleteToggle
                )
                .frame(width: 75) // 크기 조절
            }
            
            Spacer(minLength: 4) // 최소 간격 설정
            
            // 휴식/재개 버튼
            CompleteButton(
                set: set,
                disableCompleteButton: disableCompleteButton,
                onCompleteToggle: onCompleteToggle,
                onValidation: validateInputs
            )
        }
        .padding(.vertical, 4) // 상하 패딩 축소
    }
    
    // 입력값 유효성 검증
    private func validateInputs() -> Bool {
        // 무게와 횟수 검증
        let isWeightValid = !weightString.isEmpty && Double(weightString.replacingOccurrences(of: ",", with: ".")) != nil
        let isRepsValid = !repsString.isEmpty && Int(repsString) != nil
        
        // 경고 상태 업데이트
        showWeightWarning = !isWeightValid
        showRepsWarning = !isRepsValid
        
        // 모두 유효한 경우에만 true 반환
        return isWeightValid && isRepsValid
    }
}
