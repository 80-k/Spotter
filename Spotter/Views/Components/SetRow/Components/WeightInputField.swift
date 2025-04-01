// WeightInputField.swift
// 무게 입력 필드 컴포넌트
// Created by woo on 3/29/25.

import SwiftUI

// 무게 입력 필드 컴포넌트
struct WeightInputField: View {
    var weight: Double
    var isCompleted: Bool
    @Binding var isFocused: Bool
    @Binding var weightString: String
    @Binding var showWarning: Bool
    var disableCompleteButton: Bool
    var onWeightChanged: (Double) -> Void
    var onCompleteToggle: () -> Void
    
    @FocusState private var focusField: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            HStack(spacing: 2) {
                weightTextField
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
    
    // 무게 텍스트 필드
    private var weightTextField: some View {
        Group {
            if isCompleted {
                // 완료 상태: 텍스트로 표시
                Text(formatWeightValue(weight))
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(SpotColor.text)
                    .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !disableCompleteButton {
                            onCompleteToggle()
                        }
                    }
                    .onAppear {
                        weightString = formatWeightValue(weight)
                    }
            } else {
                // 미완료 상태: 입력 필드
                HStack(spacing: 0) {
                    TextField("0", text: $weightString)
                        .font(.system(size: 15, weight: .medium))
                        .keyboardType(.decimalPad)
                        .multilineTextAlignment(.leading)
                        .focused($focusField)
                        .onChange(of: weightString) { _, newValue in
                            handleWeightChange(newValue)
                        }
                        .onSubmit {
                            // Return 키 누를 때 다음 필드로 이동
                            focusField = false
                        }
                        // 이벤트 전파 중지
                        .contentShape(Rectangle())
                        .onTapGesture {}
                    
                    // 입력 중일 때만 X 버튼 표시
                    if isFocused && !weightString.isEmpty {
                        ClearButton {
                            weightString = ""
                            onWeightChanged(0)
                        }
                        .transition(.opacity)
                        .animation(.easeInOut(duration: 0.2), value: isFocused && !weightString.isEmpty)
                    }
                }
                .frame(minWidth: 40, idealWidth: 50, maxWidth: 55, alignment: .leading)
                .onAppear {
                    weightString = formatWeightValue(weight)
                }
            }
        }
    }
    
    // 무게 변경 처리
    private func handleWeightChange(_ newValue: String) {
        // 쉼표를 점으로 자동 변환
        var processedValue = newValue
        if newValue.contains(",") {
            processedValue = newValue.replacingOccurrences(of: ",", with: ".")
        }
        
        if !processedValue.isEmpty {
            showWarning = false
        }
        
        // 숫자와 소수점만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789.")
        let validCharsString = processedValue.unicodeScalars.filter { validChars.contains($0) }
        if String(validCharsString) != processedValue {
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
        
        // 실수 값으로 변환
        if let weight = Double(weightString) {
            onWeightChanged(weight)
        }
    }
} 