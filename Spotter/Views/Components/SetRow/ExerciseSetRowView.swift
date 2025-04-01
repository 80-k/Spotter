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
    
    // 툴바 표시 여부 제어용 상태
    @State private var showKeyboardToolbar: Bool = false
    
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
            .onChange(of: isWeightFocused) { _, newValue in
                // 툴바 표시 여부 업데이트
                if newValue {
                    showKeyboardToolbar = true
                } else if !isRepsFocused {
                    showKeyboardToolbar = false
                }
            }
            .onChange(of: isRepsFocused) { _, newValue in
                // 툴바 표시 여부 업데이트
                if newValue {
                    showKeyboardToolbar = true
                } else if !isWeightFocused {
                    showKeyboardToolbar = false
                }
            }
            // 표준 SwiftUI 툴바 - 'if' 구문으로 감싸지 않고 toolbar 모디파이어 내에서 제어
            .toolbar {
                ToolbarItemGroup(placement: .keyboard) {
                    if showKeyboardToolbar {
                        HStack(spacing: 8) {
                            // 왼쪽에 '비우기' 버튼
                            Button(action: {
                                // 현재 활성화된 입력창 비우기
                                if isWeightFocused {
                                    weightString = ""
                                    onWeightChanged(0)
                                } else if isRepsFocused {
                                    repsString = ""
                                    onRepsChanged(0)
                                }
                            }) {
                                Text("비우기")
                                    .fontWeight(.medium)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundColor(SpotColor.primary)
                                    .background(Color.gray.opacity(0.1))
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 4)
                            
                            // 오른쪽에 '다음/확인' 버튼
                            Button(action: {
                                if isWeightFocused {
                                    // 포커스를 한번에 변경하여 키보드가 내려갔다 올라오는 현상 방지
                                    DispatchQueue.main.async {
                                        isRepsFocused = true
                                        isWeightFocused = false
                                    }
                                } else if isRepsFocused {
                                    isRepsFocused = false
                                }
                            }) {
                                Text(isWeightFocused ? "다음" : "확인")
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 8)
                                    .foregroundColor(.white)
                                    .background(SpotColor.primary)
                                    .cornerRadius(8)
                            }
                            .padding(.horizontal, 4)
                        }
                    }
                }
            }
    }
    
    // 기본 세트 행 - 레이아웃 개선
    private var setRow: some View {
        HStack(spacing: 8) { // 좌우 간격 축소
            // 세트 번호
            setNumberCircle
                .frame(width: 32) // 크기 약간 축소
            
            // 무게 및 횟수 입력 영역 - 너비 조절
            HStack(spacing: 10) { // 간격 약간 넓힘
                // 무게 입력 영역
                weightInputField
                    .frame(width: 85) // 크기 조절
                
                // 횟수 입력 영역
                repsInputField
                    .frame(width: 75) // 크기 조절
            }
            
            Spacer(minLength: 4) // 최소 간격 설정
            
            // 휴식/재개 버튼
            completeButton
        }
        .padding(.vertical, 4) // 상하 패딩 축소
    }
    
    // 세트 번호 원 - 색상 통일성 개선
    private var setNumberCircle: some View {
        ZStack {
            Circle()
                .fill(set.isCompleted ? SpotColor.success.opacity(0.12) : SpotColor.primary.opacity(0.12))
                .frame(width: 32, height: 32)
            
            Text("\(setNumber)")
                .font(.callout) // 크기 조절
                .fontWeight(.medium)
                .foregroundColor(set.isCompleted ? SpotColor.success : SpotColor.primary)
        }
    }
    
    // 무게 입력 필드 - 애플 디자인 원칙 적용
    private var weightInputField: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 2) {
                weightTextField
                    .layoutPriority(1)
            }
            .frame(height: 34) // 높이 축소
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(weightFieldBackground)
            )
            // 테두리를 포커스 상태에만 표시
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(weightFieldBorder, lineWidth: isWeightFocused || showWeightWarning ? 1 : 0)
            )
        }
    }
    
    // 무게 텍스트 필드 - 개선된 버전
    private var weightTextField: some View {
        Group {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                // 정수면 정수로, 소수점 있으면 소수점 포함 표시
                Text(formatWeightValue(set.weight))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !disableCompleteButton {
                            onCompleteToggle() // 터치하면 완료 상태 토글
                        }
                    }
                    .onAppear {
                        // 상태가 변경되면 표시 값 업데이트
                        weightString = formatWeightValue(set.weight)
                    }
            } else {
                // 미완료 상태: 입력 필드
                HStack(spacing: 0) {
                    TextField("0", text: $weightString)
                        .font(.system(size: 15, weight: .medium))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .focused($isWeightFocused)
                        .onChange(of: weightString) { oldValue, newValue in
                            handleWeightChange(newValue)
                        }
                        .onSubmit {
                            // Return 키 누를 때 다음 필드로 포커스 이동
                            isWeightFocused = false
                            isRepsFocused = true
                        }
                        // 입력 도중에 다른 영역 탭 시 이벤트가 전파되지 않도록 수정
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 이벤트 전파 중지
                        }
                    
                    // 입력 중일 때만 X 버튼 표시
                    if isWeightFocused && !weightString.isEmpty {
                        Button(action: {
                            weightString = ""
                            onWeightChanged(0)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.7))
                                .font(.system(size: 14))
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isWeightFocused && !weightString.isEmpty)
                    }
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading)
                .onAppear {
                    // 상태가 변경되면 표시 값 업데이트
                    weightString = formatWeightValue(set.weight)
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
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 2) {
                repsTextField
                    .layoutPriority(1)
            }
            .frame(height: 34) // 높이 축소
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(repsFieldBackground)
            )
            // 테두리를 포커스 상태에만 표시
            .overlay(
                RoundedRectangle(cornerRadius: 6)
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
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading)
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
                HStack(spacing: 0) {
                    TextField("0", text: $repsString)
                        .font(.system(size: 15, weight: .medium))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .focused($isRepsFocused)
                        .onChange(of: repsString) { oldValue, newValue in
                            handleRepsChange(newValue)
                        }
                        .onSubmit {
                            // Return 키 누를 때 키보드 내리기
                            isRepsFocused = false
                        }
                        // 입력 도중에 다른 영역 탭 시 이벤트가 전파되지 않도록 수정
                        .contentShape(Rectangle())
                        .onTapGesture {
                            // 이벤트 전파 중지
                        }
                    
                    // 입력 중일 때만 X 버튼 표시
                    if isRepsFocused && !repsString.isEmpty {
                        Button(action: {
                            repsString = ""
                            onRepsChanged(0)
                        }) {
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.gray.opacity(0.7))
                                .font(.system(size: 14))
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isRepsFocused && !repsString.isEmpty)
                    }
                }
                .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading)
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
                .font(.system(size: 9, weight: .semibold))
                .foregroundColor(SpotColor.success)
            
            Text("재개")
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(SpotColor.success)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            Capsule()
                .fill(SpotColor.success.opacity(0.1))
        )
    }
    
    // 미완료 상태 버튼 - 애플 디자인 스타일 적용
    private var incompleteButton: some View {
        Text("휴식")
            .font(.system(size: 11, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 5)
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
        
        // 숫자와 소수점만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789.")
        let validCharsString = newValue.unicodeScalars.filter { validChars.contains($0) }
        if String(validCharsString) != newValue {
            weightString = String(validCharsString)
            return
        }
        
        // 소수점이 중복으로 있는 경우 처리
        let components = weightString.components(separatedBy: ".")
        if components.count > 2 {
            let firstPart = components.first ?? ""
            let restParts = components.dropFirst().joined()
            weightString = firstPart + "." + restParts
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
    
    // 무게 값 포맷팅 함수 추가
    private func formatWeightValue(_ weight: Double) -> String {
        if weight <= 0 {
            return "0"
        }
        
        // 소수점 이하가 0인지 확인 (정수인지)
        let isInteger = weight.truncatingRemainder(dividingBy: 1) == 0
        
        if isInteger {
            return "\(Int(weight))"
        } else {
            return String(format: "%.1f", weight)
        }
    }
}
