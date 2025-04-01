// RepsInputField.swift
// 반복 횟수 입력 필드 컴포넌트
// Created by woo on 3/29/25.

import SwiftUI

// 횟수 입력 필드 컴포넌트
struct RepsInputField: View {
    var reps: Int
    var isCompleted: Bool
    @Binding var isFocused: Bool
    @Binding var repsString: String
    @Binding var showWarning: Bool
    var disableCompleteButton: Bool
    var onRepsChanged: (Int) -> Void
    var onCompleteToggle: () -> Void
    
    @FocusState private var focusField: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 2) {
                repsTextField
                    .layoutPriority(1)
            }
            .frame(height: 34)
            .padding(.horizontal, 8)
            .background(
                RoundedRectangle(cornerRadius: 6)
                    .fill(getFieldBackgroundColor(showWarning: showWarning, 
                                                  isFocused: isFocused, 
                                                  isCompleted: isCompleted))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 6)
                    .stroke(getFieldBorderColor(showWarning: showWarning, 
                                               isFocused: isFocused, 
                                               isCompleted: isCompleted), 
                            lineWidth: isFocused || showWarning ? 1 : 0)
            )
        }
        .manageFocus(from: $focusField, to: $isFocused)
    }
    
    // 횟수 텍스트 필드
    private var repsTextField: some View {
        Group {
            if isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(reps > 0 ? "\(reps)" : "0")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !disableCompleteButton {
                            onCompleteToggle()
                        }
                    }
                    .onAppear {
                        repsString = reps > 0 ? "\(reps)" : ""
                    }
            } else {
                // 미완료 상태: 입력 필드
                HStack(spacing: 0) {
                    TextField("0", text: $repsString)
                        .font(.system(size: 15, weight: .medium))
                        .keyboardType(.numberPad)
                        .multilineTextAlignment(.leading)
                        .focused($focusField)
                        .onChange(of: repsString) { _, newValue in
                            handleRepsChange(newValue)
                        }
                        .onSubmit {
                            focusField = false
                        }
                        // 이벤트 전파 중지
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    // 입력 중일 때만 X 버튼 표시
                    if isFocused && !repsString.isEmpty {
                        ClearButton {
                            repsString = ""
                            onRepsChanged(0)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isFocused && !repsString.isEmpty)
                    }
                }
                .frame(minWidth: 30, idealWidth: 40, maxWidth: 45, alignment: .leading)
                .onAppear {
                    repsString = reps > 0 ? "\(reps)" : ""
                }
            }
        }
    }
    
    // 횟수 변경 처리
    private func handleRepsChange(_ newValue: String) {
        if !newValue.isEmpty {
            showWarning = false
        }
        
        // 숫자만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789")
        let validCharsString = newValue.unicodeScalars.filter { validChars.contains($0) }
        if String(validCharsString) != newValue {
            repsString = String(validCharsString)
            return
        }
        
        // 정수 값으로 변환
        if let reps = Int(repsString) {
            onRepsChanged(reps)
        }
    }
} 