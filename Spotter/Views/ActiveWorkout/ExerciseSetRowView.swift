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
    var disableComplete: Bool
    
    @State private var weightString: String = ""
    @State private var repsString: String = ""
    @State private var showWeightWarning: Bool = false
    @State private var showRepsWarning: Bool = false
    
    // 타이머 관련 상태
    @State private var isTimerActive: Bool = false
    @State private var remainingTime: TimeInterval = 0
    @State private var timer: Timer? = nil
    
    
    init(set: WorkoutSet, setNumber: Int, onWeightChanged: @escaping (Double) -> Void, onRepsChanged: @escaping (Int) -> Void, onCompleteToggle: @escaping () -> Void, disableComplete: Bool = false) {
        self.set = set
        self.setNumber = setNumber
        self.onWeightChanged = onWeightChanged
        self.onRepsChanged = onRepsChanged
        self.onCompleteToggle = onCompleteToggle
        self.disableComplete = disableComplete
        
        self._weightString = State(initialValue: set.weight > 0 ? String(format: "%.1f", set.weight) : "")
        self._repsString = State(initialValue: set.reps > 0 ? "\(set.reps)" : "")
        self._isTimerActive = State(initialValue: set.isCompleted)
        self._remainingTime = State(initialValue: set.isCompleted ? set.remainingRestTime : set.restTime)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // 세트 기본 행
            setRow
            
            // 타이머 영역
            if set.isCompleted && isTimerActive {
                timerView
            }
        }
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray.opacity(0.1), lineWidth: 1)
        )
        .padding(.horizontal, 8)
        .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isTimerActive)
        .onAppear {
            setupOnAppear()
        }
        .onDisappear {
            stopTimer()
        }
    }
    
    // 기본 세트 행
    private var setRow: some View {
        HStack(spacing: 10) {
            // 세트 번호
            Text("\(setNumber)")
                .font(.headline)
                .frame(width: 30)
                .foregroundColor(.primary)
            
            // 무게 입력 영역
            weightInputField
            
            // 횟수 입력 영역
            repsInputField
            
            Spacer()
            
            // 완료/재개 버튼
            completeButton
        }
        .padding(.vertical, 8)
        .padding(.horizontal)
        .background(set.isCompleted ? Color.gray.opacity(0.05) : Color.clear)
    }
    
    // 무게 입력 필드
    private var weightInputField: some View {
        HStack(spacing: 4) {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(weightString.isEmpty ? "0" : weightString)
                    .foregroundColor(.secondary)
            } else {
                // 미완료 상태: 입력 필드
                TextField("무게", text: $weightString)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: weightString) { oldValue, newValue in
                        if !newValue.isEmpty {
                            showWeightWarning = false
                        }
                    }
                    .onSubmit {
                        updateWeight()
                    }
            }
            
            Text("kg")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(width: 80)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(showWeightWarning ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(showWeightWarning ? Color.red : Color.clear, lineWidth: 1)
        )
    }
    
    // 반복 횟수 입력 필드
    private var repsInputField: some View {
        HStack(spacing: 4) {
            if set.isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(repsString.isEmpty ? "0" : repsString)
                    .foregroundColor(.secondary)
            } else {
                // 미완료 상태: 입력 필드
                TextField("횟수", text: $repsString)
                    .keyboardType(.numberPad)
                    .multilineTextAlignment(.trailing)
                    .onChange(of: repsString) { oldValue, newValue in
                        if !newValue.isEmpty {
                            showRepsWarning = false
                        }
                    }
                    .onSubmit {
                        updateReps()
                    }
            }
            
            Text("rep")
                .font(.callout)
                .foregroundColor(.secondary)
        }
        .frame(width: 70)
        .padding(6)
        .background(
            RoundedRectangle(cornerRadius: 5)
                .fill(showRepsWarning ? Color.red.opacity(0.2) : Color.gray.opacity(0.1))
        )
        .overlay(
            RoundedRectangle(cornerRadius: 5)
                .stroke(showRepsWarning ? Color.red : Color.clear, lineWidth: 1)
        )
    }
    
    // 완료 버튼
    private var completeButton: some View {
        Button(action: onCompleteButtonTapped) {
            if set.isCompleted {
                // 완료 상태 버튼
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.green)
                    .font(.system(size: 24))
            } else {
                // 미완료 상태 버튼
                Text("완료")
                    .font(.caption)
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(disableComplete ? Color.gray : Color.blue)
                    .cornerRadius(5)
            }
        }
        .disabled(disableComplete && !set.isCompleted) // 비활성화 속성 추가
    }
    
    // 타이머 뷰
    private var timerView: some View {
        VStack(spacing: 12) {
            Divider()
                .padding(.horizontal)
            
            // 타이머 컴포넌트
            HStack {
                Spacer()
                
                ZStack {
                    // 타이머 배경 원
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 6)
                        .frame(width: 100, height: 100)
                    
                    // 타이머 진행 원
                    timerProgressCircle
                    
                    // 타이머 텍스트
                    timerText
                }
                
                Spacer()
            }
            .padding(.vertical, 16)
        }
        .background(Color.gray.opacity(0.05))
        .transition(.opacity.combined(with: .move(edge: .top)))
    }
    
    // 타이머 진행 원
    private var timerProgressCircle: some View {
        Circle()
            .trim(from: 0, to: CGFloat(remainingTime / set.restTime))
            .stroke(Color.blue, style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .frame(width: 100, height: 100)
            .rotationEffect(.degrees(-90))
    }
    
    // 타이머 텍스트
    private var timerText: some View {
        VStack {
            Text(formatTime(remainingTime))
                .font(.title2)
                .fontWeight(.bold)
                .monospacedDigit()
            
            Text("휴식")
                .font(.caption)
                .foregroundColor(.secondary)
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
            
            // 타이머 활성화
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isTimerActive = true
                remainingTime = set.restTime
            }
            
            // 타이머 시작
            startTimer()
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
        // 타이머 비활성화
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            isTimerActive = false
        }
        
        // 타이머 종료
        stopTimer()
        
        // 이미 완료된 세트는 재개 가능
        onCompleteToggle()
    }
    
    // onAppear 설정
    private func setupOnAppear() {
        // 뷰가 나타날 때 세트가 완료 상태면 타이머 확인
        if set.isCompleted {
            remainingTime = set.remainingRestTime
            if remainingTime > 0 {
                isTimerActive = true
                startTimer()
            } else {
                isTimerActive = false
            }
        }
    }
    
    // 타이머 시작
    private func startTimer() {
        // 기존 타이머 정리
        stopTimer()
        
        // 타이머 시작 (1초마다 업데이트)
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
            if remainingTime > 0 {
                remainingTime -= 1
            } else {
                // 시간이 종료되면 타이머 숨기기
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isTimerActive = false
                }
                
                // 알림 진동
                #if os(iOS)
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.success)
                #endif
                
                stopTimer()
            }
        }
        
        // 타이머를 메인 스레드에 등록
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    // 타이머 정지
    private func stopTimer() {
        timer?.invalidate()
        timer = nil
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
    
    // 시간 포맷팅
    private func formatTime(_ seconds: TimeInterval) -> String {
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
}
