// ExerciseSetRowView.swift
// 운동 세트 행 컴포넌트
//  Created by woo on 3/29/25.

import SwiftUI

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
        
        self._weightString = State(initialValue: set.weight > 0 ? String(format: "%.1f", set.weight) : "")
        self._repsString = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
    }
    
    var body: some View {
        // 세트 기본 행
        setRow
        .padding(10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(set.isCompleted ? SpotColor.completedSet.opacity(0.1) : Color(.secondarySystemGroupedBackground))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 12)
                .stroke(set.isCompleted ? SpotColor.success.opacity(0.2) : Color.clear, lineWidth: 1)
        )
        .shadow(color: Color.primary.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
    }
    
    // 배경색 계산
    private var setBackground: Color {
        return set.isCompleted ? Color.green.opacity(0.05) : Color.white
    }
    
    // 테두리색 계산
    private var setBorder: Color {
        return set.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    // 기본 세트 행 - 레이아웃 개선
    private var setRow: some View {
        HStack(spacing: 8) { // 좌우 간격 축소
            // 세트 번호
            setNumberCircle
                .frame(width: 36) // 고정 너비 적용
            
            // 무게 및 횟수 입력 영역 - 너비 조절
            HStack(spacing: 8) { // 간격 축소
                // 무게 입력 영역
                weightInputField
                    .frame(width: 90) // 너비 조절
                
                // 횟수 입력 영역
                repsInputField
                    .frame(width: 80) // 너비 조절
            }
            
            Spacer(minLength: 4) // 최소 간격 설정
            
            // 휴식/재개 버튼
            completeButton
        }
        .padding(.vertical, 6)
    }
    
    // 세트 번호 원 - 색상 통일성 개선
    private var setNumberCircle: some View {
        ZStack {
            Circle()
                .fill(set.isCompleted ? SpotColor.success.opacity(0.15) : SpotColor.primary.opacity(0.15))
                .frame(width: 36, height: 36)
            
            Text("\(setNumber)")
                .font(.headline)
                .foregroundColor(set.isCompleted ? SpotColor.success : SpotColor.primary)
        }
    }
    
    // 무게 입력 필드 - 애플 디자인 원칙 적용
    private var weightInputField: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("무게")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(SpotColor.secondaryText)
            
            HStack(spacing: 2) {
                weightTextField
                    .layoutPriority(1)
                
                Text("kg")
                    .font(.caption)
                    .foregroundColor(SpotColor.secondaryText)
                    .layoutPriority(2)
            }
            .frame(height: 36) // 높이 축소
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(weightFieldBackground)
            )
            // 테두리를 포커스 상태에만 표시
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(weightFieldBorder, lineWidth: isWeightFocused || showWeightWarning ? 1 : 0)
            )
        }
    }
    
    // 무게 텍스트 필드 - 개선된 버전
    private var weightTextField: some View {
        Group {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                // 세트의 실제 무게값을 항상 사용
                Text(set.weight > 0 ? String(format: "%.1f", set.weight) : "0")
                    .font(.system(size: 16, weight: .medium)) // 폰트 크기 축소
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading) // 유연한 너비 설정
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !disableCompleteButton {
                            onCompleteToggle() // 터치하면 완료 상태 토글
                        }
                    }
                    .onAppear {
                        // 상태가 변경되면 표시 값 업데이트
                        weightString = set.weight > 0 ? String(format: "%.1f", set.weight) : ""
                    }
            } else {
                // 미완료 상태: 입력 필드
                TextField("0", text: $weightString)
                    .font(.system(size: 16, weight: .medium)) // 폰트 크기 축소
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.leading)
                    .focused($isWeightFocused)
                    .onChange(of: weightString) { oldValue, newValue in
                        handleWeightChange(newValue)
                    }
                    .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading) // 유연한 너비 설정
                    .onAppear {
                        // 상태가 변경되면 표시 값 업데이트
                        weightString = set.weight > 0 ? String(format: "%.1f", set.weight) : ""
                    }
            }
        }
    }
    
    // 무게 필드 배경색 - 애플 디자인 스타일 적용
    private var weightFieldBackground: Color {
        if showWeightWarning {
            return SpotColor.danger.opacity(0.08)
        } else if isWeightFocused {
            return SpotColor.inputFocused.opacity(0.08)
        } else if set.isCompleted {
            return SpotColor.completedSet.opacity(0.08)
        } else {
            return Color(.tertiarySystemGroupedBackground)
        }
    }
    
    // 무게 필드 테두리색 - 애플 디자인 스타일 적용
    private var weightFieldBorder: Color {
        if showWeightWarning {
            return SpotColor.danger
        } else if isWeightFocused {
            return SpotColor.primary
        } else if set.isCompleted {
            return SpotColor.success
        } else {
            return Color.clear
        }
    }
    
    // 반복 횟수 입력 필드 - 애플 디자인 원칙 적용
    private var repsInputField: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("횟수")
                .font(.caption2)
                .fontWeight(.medium)
                .foregroundColor(SpotColor.secondaryText)
            
            HStack(spacing: 2) {
                repsTextField
                    .layoutPriority(1)
                
                Text("회")
                    .font(.caption)
                    .foregroundColor(SpotColor.secondaryText)
                    .layoutPriority(2)
            }
            .frame(height: 36) // 높이 축소
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(repsFieldBackground)
            )
            // 테두리를 포커스 상태에만 표시
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(repsFieldBorder, lineWidth: isRepsFocused || showRepsWarning ? 1 : 0)
            )
        }
    }
    
    // 횟수 텍스트 필드 - 개선된 버전
    private var repsTextField: some View {
        Group {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                // 세트의 실제 횟수값을 항상 사용
                Text(set.reps > 0 ? "\(set.reps)" : "0")
                    .font(.system(size: 16, weight: .medium)) // 폰트 크기 축소
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading) // 유연한 너비 설정
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !disableCompleteButton {
                            onCompleteToggle() // 터치하면 완료 상태 토글
                        }
                    }
                    .onAppear {
                        // 상태가 변경되면 표시 값 업데이트
                        repsString = set.reps > 0 ? "\(set.reps)" : ""
                    }
            } else {
                // 미완료 상태: 입력 필드
                TextField("0", text: $repsString)
                    .font(.system(size: 16, weight: .medium)) // 폰트 크기 축소
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.leading)
                    .focused($isRepsFocused)
                    .onChange(of: repsString) { oldValue, newValue in
                        handleRepsChange(newValue)
                    }
                    .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading) // 유연한 너비 설정
                    .onAppear {
                        // 상태가 변경되면 표시 값 업데이트
                        repsString = set.reps > 0 ? "\(set.reps)" : ""
                    }
            }
        }
    }
    
    // 횟수 필드 배경색 - 애플 디자인 스타일 적용
    private var repsFieldBackground: Color {
        if showRepsWarning {
            return SpotColor.danger.opacity(0.08)
        } else if isRepsFocused {
            return SpotColor.inputFocused.opacity(0.08)
        } else if set.isCompleted {
            return SpotColor.completedSet.opacity(0.08)
        } else {
            return Color(.tertiarySystemGroupedBackground)
        }
    }
    
    // 횟수 필드 테두리색 - 애플 디자인 스타일 적용
    private var repsFieldBorder: Color {
        if showRepsWarning {
            return SpotColor.danger
        } else if isRepsFocused {
            return SpotColor.primary
        } else if set.isCompleted {
            return SpotColor.success
        } else {
            return Color.clear
        }
    }
    
    // 완료 버튼
    private var completeButton: some View {
        Button(action: onCompleteButtonTapped) {
            if set.isCompleted {
                completedButton
            } else {
                incompleteButton
            }
        }
        .disabled(disableCompleteButton && !set.isCompleted) // 완료 버튼만 비활성화
    }
    
    // 완료된 상태 버튼 - 애플 디자인 스타일 적용
    private var completedButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "timer")
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(SpotColor.success)
            
            Text("재개")
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(SpotColor.success)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(SpotColor.success.opacity(0.1))
        )
    }
    
    // 미완료 상태 버튼 - 애플 디자인 스타일 적용
    private var incompleteButton: some View {
        Text("휴식")
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(disableCompleteButton ? Color(.systemGray3) : SpotColor.primary)
            )
    }
    
    // 무게 변경 처리
    private func handleWeightChange(_ newValue: String) {
        // 쉼표를 점으로 자동 변환
        if newValue.contains(",") {
            weightString = newValue.replacingOccurrences(of: ",", with: ".")
        }
        
        if !newValue.isEmpty {
            showWeightWarning = false
        }
        
        // 숫자만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789.")
        let validCharsString = newValue.unicodeScalars.filter { validChars.contains($0) }
        if String(validCharsString) != newValue {
            weightString = String(validCharsString)
            return
        }
        
        // 실수 값으로 변환 가능하면 즉시 업데이트
        if let weight = Double(weightString) {
            onWeightChanged(weight)
        }
    }
    
    // 횟수 변경 처리
    private func handleRepsChange(_ newValue: String) {
        if !newValue.isEmpty {
            showRepsWarning = false
        }
        
        // 숫자만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789")
        let validCharsString = newValue.unicodeScalars.filter { validChars.contains($0) }
        if String(validCharsString) != newValue {
            repsString = String(validCharsString)
            return
        }
        
        // 정수 값으로 변환 가능하면 즉시 업데이트
        if let reps = Int(repsString) {
            onRepsChanged(reps)
        }
    }
    
    // 완료 버튼 탭 처리
    private func onCompleteButtonTapped() {
        if !set.isCompleted {
            handleSetCompletion()
        } else {
            handleSetResume()
        }
    }
    
    // 세트 완료 처리
    private func handleSetCompletion() {
        // 무게와 횟수 검증
        let isWeightValid = !weightString.isEmpty && Double(weightString.replacingOccurrences(of: ",", with: ".")) != nil
        let isRepsValid = !repsString.isEmpty && Int(repsString) != nil
        
        // 경고 상태 업데이트
        showWeightWarning = !isWeightValid
        showRepsWarning = !isRepsValid
        
        // 둘 다 유효한 경우에만 완료 처리
        if isWeightValid && isRepsValid {
            // 무게와 횟수 업데이트
            updateWeight()
            updateReps()
            
            // 상태 변경 전에 무게와 횟수가 저장되었는지 확인
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                onCompleteToggle()
            }
            
            // 진동 피드백 (완료)
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
            #endif
        } else {
            // 진동 피드백 (경고)
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.warning)
            #endif
        }
    }
    
    // 세트 재개 처리
    private func handleSetResume() {
        // 이미 완료된 세트는 재개 가능
        onCompleteToggle()
    }
    
    // 무게 업데이트
    private func updateWeight() {
        if let weight = Double(weightString.replacingOccurrences(of: ",", with: ".")) {
            onWeightChanged(weight)
        }
    }
    
    // 횟수 업데이트
    private func updateReps() {
        if let reps = Int(repsString) {
            onRepsChanged(reps)
        }
    }
}
