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
        .padding(8)
        .background(set.isCompleted ? Color.green.opacity(0.05) : Color.white)
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(set.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.2), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.03), radius: 2, x: 0, y: 1)
        .padding(.horizontal, 8)
        .padding(.vertical, 2)
    }
    
    // 배경색 계산
    private var setBackground: Color {
        return set.isCompleted ? Color.green.opacity(0.05) : Color.white
    }
    
    // 테두리색 계산
    private var setBorder: Color {
        return set.isCompleted ? Color.green.opacity(0.3) : Color.gray.opacity(0.2)
    }
    
    // 기본 세트 행
    private var setRow: some View {
        HStack(spacing: 12) {
            // 세트 번호
            setNumberCircle
            
            // 무게 및 횟수 입력 영역
            HStack(spacing: 16) {
                // 무게 입력 영역
                weightInputField
                
                // 횟수 입력 영역
                repsInputField
            }
            
            Spacer()
            
            // 완료/재개 버튼
            completeButton
        }
        .padding(.vertical, 6)
    }
    
    // 세트 번호 원
    private var setNumberCircle: some View {
        ZStack {
            Circle()
                .fill(set.isCompleted ? Color.green.opacity(0.1) : Color.blue.opacity(0.1))
                .frame(width: 32, height: 32)
            
            Text("\(setNumber)")
                .font(.headline)
                .foregroundColor(set.isCompleted ? .green : .blue)
        }
    }
    
    // 무게 입력 필드
    private var weightInputField: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("무게")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                weightTextField
                
                Text("kg")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(weightFieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(weightFieldBorder, lineWidth: 1)
            )
        }
    }
    
    // 무게 텍스트 필드
    private var weightTextField: some View {
        Group {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(weightString.isEmpty ? "0" : weightString)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            } else {
                // 미완료 상태: 입력 필드
                TextField("0", text: $weightString)
                    .font(.system(size: 16, weight: .medium))
                    .keyboardType(.decimalPad)
                    .focused($isWeightFocused)
                    .onChange(of: weightString) { oldValue, newValue in
                        handleWeightChange(newValue)
                    }
                    .frame(width: 50)
            }
        }
    }
    
    // 무게 필드 배경색
    private var weightFieldBackground: Color {
        if showWeightWarning {
            return Color.red.opacity(0.1)
        } else if isWeightFocused {
            return Color.blue.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    // 무게 필드 테두리색
    private var weightFieldBorder: Color {
        if showWeightWarning {
            return Color.red.opacity(0.5)
        } else if isWeightFocused {
            return Color.blue.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    // 반복 횟수 입력 필드
    private var repsInputField: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("횟수")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                repsTextField
                
                Text("회")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(repsFieldBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(repsFieldBorder, lineWidth: 1)
            )
        }
    }
    
    // 횟수 텍스트 필드
    private var repsTextField: some View {
        Group {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(repsString.isEmpty ? "0" : repsString)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
            } else {
                // 미완료 상태: 입력 필드
                TextField("0", text: $repsString)
                    .font(.system(size: 16, weight: .medium))
                    .keyboardType(.numberPad)
                    .focused($isRepsFocused)
                    .onChange(of: repsString) { oldValue, newValue in
                        handleRepsChange(newValue)
                    }
                    .frame(width: 40)
            }
        }
    }
    
    // 횟수 필드 배경색
    private var repsFieldBackground: Color {
        if showRepsWarning {
            return Color.red.opacity(0.1)
        } else if isRepsFocused {
            return Color.blue.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    // 횟수 필드 테두리색
    private var repsFieldBorder: Color {
        if showRepsWarning {
            return Color.red.opacity(0.5)
        } else if isRepsFocused {
            return Color.blue.opacity(0.3)
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
    
    // 완료된 상태 버튼
    private var completedButton: some View {
        HStack(spacing: 4) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
            
            Text("완료")
                .font(.caption)
                .foregroundColor(.green)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 6)
        .background(Color.green.opacity(0.1))
        .cornerRadius(5)
    }
    
    // 미완료 상태 버튼
    private var incompleteButton: some View {
        Text("완료")
            .font(.caption)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(disableCompleteButton ? Color.gray : Color.blue)
            .cornerRadius(5)
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
            updateWeight()
            updateReps()
            onCompleteToggle()
            
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
