// ExerciseSetRowView.swift
// 운동 세트 행 컴포넌트
//  Created by woo on 3/29/25.

import SwiftUI
import Combine
import SwiftData
import os
import Foundation

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "ExerciseSetRowView")

struct ExerciseSetRowView: View {
    var set: WorkoutSet
    let setNumber: Int
    
    var onWeightChanged: (Double) -> Void
    var onRepsChanged: (Int) -> Void
    var onCompleteToggle: () -> Void
    var onDelete: (() -> Void)? = nil
    var disableCompleteButton: Bool  // 완료 버튼만 비활성화하는 플래그
    
    @FocusState private var isWeightFocused: Bool
    @FocusState private var isRepsFocused: Bool
    
    @State private var weightString: String = ""
    @State private var repsString: String = ""
    @State private var showWeightWarning: Bool = false
    @State private var showRepsWarning: Bool = false
    
    // 강조 모드 상태 관리
    @Binding var isHighlighted: Bool
    // 선택된 세트 ID 관리 (전역)
    @Binding var selectedSetID: UUID?
    
    init(set: WorkoutSet, setNumber: Int, 
         onWeightChanged: @escaping (Double) -> Void, 
         onRepsChanged: @escaping (Int) -> Void, 
         onCompleteToggle: @escaping () -> Void, 
         onDelete: (() -> Void)? = nil,
         disableCompleteButton: Bool = false,
         isHighlighted: Binding<Bool> = .constant(false),
         selectedSetID: Binding<UUID?> = .constant(nil)) {
        self.set = set
        self.setNumber = setNumber
        self.onWeightChanged = onWeightChanged
        self.onRepsChanged = onRepsChanged
        self.onCompleteToggle = onCompleteToggle
        self.onDelete = onDelete
        self.disableCompleteButton = disableCompleteButton
        self._isHighlighted = isHighlighted
        self._selectedSetID = selectedSetID
        
        // 무게값 표시 방식 변경 - 정수면 정수로, 소수점 있으면 소수점 포함 표시
        let weight = set.weight
        let isInteger = weight.truncatingRemainder(dividingBy: 1) == 0
        self._weightString = State(initialValue: weight > 0 ? (isInteger ? "\(Int(weight))" : String(format: "%.1f", weight)) : "")
        self._repsString = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
    }
    
    var body: some View {
        setRow
            .allowsHitTesting(!isHighlighted) // 강조 모드일 때 하위 뷰 터치 비활성화
            .padding(8)
        .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(isHighlighted ? Color(.systemGray4).opacity(0.3) :
                         (set.isCompleted ? SpotColor.completedSet.opacity(0.05) : Color.clear))
        )
        .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isHighlighted ? Color.gray.opacity(0.5) :
                           (set.isCompleted ? SpotColor.success.opacity(0.15) : Color.clear), 
                           lineWidth: isHighlighted ? 1.5 : 1)
            )
            .contentShape(Rectangle())
            .onTapGesture {
                if isHighlighted {
                    // 강조 모드 중 다시 탭하면 강조 모드 해제
                    logger.debug("세트 \(setNumber) 행 탭: 강조 상태 해제")
                    isHighlighted = false
                    selectedSetID = nil
                } else {
                    // 입력 필드 외 영역 터치 시 키보드 내리기
                    logger.debug("세트 \(setNumber) 행 탭: 키보드 내리기")
                    isWeightFocused = false
                    isRepsFocused = false
                }
            }
            // 길게 누르기 제스처 추가
            .onLongPressGesture(minimumDuration: 0.5) {
                // 길게 누르면 하이라이트 효과 추가
                logger.debug("세트 \(setNumber) 길게 누름: 강조 모드 활성화")
                withAnimation(.easeInOut(duration: 0.2)) {
                    isHighlighted = true
                    // PersistentIdentifier를 UUID로 변환
                    selectedSetID = generateUUIDFromID(set.id)
                }
                // 진동 피드백 제공
                let generator = UIImpactFeedbackGenerator(style: .medium)
                generator.impactOccurred()
                
                // 모든 입력 필드 비활성화
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
            // 선택된 세트 ID가 변경되었을 때 강조 상태 업데이트
            .onChange(of: selectedSetID) { oldValue, newValue in
                updateHighlightState(oldValue: oldValue, newValue: newValue)
            }
            // 포커스 상태 변경 시 로그 기록
            .onChange(of: isWeightFocused) { _, newValue in
                if newValue {
                    logger.debug("세트 \(setNumber) 무게 입력 필드 포커스됨")
                }
            }
            .onChange(of: isRepsFocused) { _, newValue in
                if newValue {
                    logger.debug("세트 \(setNumber) 횟수 입력 필드 포커스됨")
                }
            }
            // 강조 상태 변경 시 로그 기록
            .onChange(of: isHighlighted) { _, newValue in
                logger.debug("세트 \(setNumber) 강조 상태 변경: \(newValue)")
            }
    }
    
    // 강조 상태 업데이트 로직을 분리
    private func updateHighlightState(oldValue: UUID?, newValue: UUID?) {
        // 현재 세트의 UUID 가져오기
        let currentSetUUID = generateUUIDFromID(set.id)
        
        // 새로 선택된 세트가 현재 세트와 다르고 현재 세트가 강조 상태일 때
        let shouldDeactivateHighlight = newValue != currentSetUUID && isHighlighted
        
        if shouldDeactivateHighlight {
            logger.debug("선택된 세트 변경: 세트 \(setNumber)의 강조 상태 해제")
            withAnimation(.easeInOut(duration: 0.2)) {
                isHighlighted = false
            }
        }
    }
    
    // PersistentIdentifier를 UUID로 변환
    private func generateUUIDFromID(_ id: PersistentIdentifier) -> UUID {
        // PersistentIdentifier를 문자열로 변환하고 해시값으로 UUID 생성
        let idString = String(describing: id)
        return UUID(uuidString: idString) ?? UUID()
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
                .allowsHitTesting(!isHighlighted) // 강조 모드일 때 터치 비활성화
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
                .allowsHitTesting(!isHighlighted) // 강조 모드일 때 터치 비활성화
                .frame(width: 75) // 크기 조절
            }
            
            Spacer(minLength: 4) // 최소 간격 설정
            
            // 휴식/재개 버튼
            CompleteButton(
                set: set,
                disableCompleteButton: disableCompleteButton || isHighlighted, // 강조 모드일 때도 버튼 비활성화
                onCompleteToggle: onCompleteToggle,
                onValidation: validateInputs
            )
            .allowsHitTesting(!isHighlighted) // 강조 모드일 때 터치 비활성화
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
