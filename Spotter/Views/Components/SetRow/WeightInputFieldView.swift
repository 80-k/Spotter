//
//  WeightInputFieldView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct WeightInputFieldView: View {
    @Binding var weightString: String
    let isCompleted: Bool
    let showWarning: Bool
    var onWeightChanged: (Double) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("무게")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if isCompleted {
                    // 완료 상태: 텍스트로 표시
                    Text(weightString.isEmpty ? "0" : weightString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    // 미완료 상태: 입력 필드
                    TextField("0", text: $weightString)
                        .font(.system(size: 16, weight: .medium))
                        .keyboardType(.decimalPad)
                        .focused($isFocused)
                        .onChange(of: weightString) { oldValue, newValue in
                            handleWeightChange(newValue)
                        }
                        .frame(width: 50)
                }
                
                Text("kg")
                    .font(.callout)
                    .foregroundColor(.secondary)
            }
            .padding(6)
            .background(
                RoundedRectangle(cornerRadius: 5)
                    .fill(backgroundColor)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5)
                    .stroke(borderColor, lineWidth: 1)
            )
        }
    }
    
    // 배경색 계산
    private var backgroundColor: Color {
        if showWarning {
            return Color.red.opacity(0.1)
        } else if isFocused {
            return Color.blue.opacity(0.1)
        } else {
            return Color.gray.opacity(0.05)
        }
    }
    
    // 테두리색 계산
    private var borderColor: Color {
        if showWarning {
            return Color.red.opacity(0.5)
        } else if isFocused {
            return Color.blue.opacity(0.3)
        } else {
            return Color.clear
        }
    }
    
    // 무게 변경 처리
    private func handleWeightChange(_ newValue: String) {
        // 쉼표를 점으로 자동 변환
        var processedValue = newValue
        if processedValue.contains(",") {
            processedValue = processedValue.replacingOccurrences(of: ",", with: ".")
            if processedValue != newValue {
                weightString = processedValue
            }
        }
        
        // 숫자만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789.")
        let filtered = String(processedValue.unicodeScalars.filter { validChars.contains($0) })
        if filtered != processedValue {
            weightString = filtered
            return
        }
        
        // 실수 값으로 변환 가능하면 즉시 업데이트
        if let weight = Double(weightString) {
            onWeightChanged(weight)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 일반 상태
        WeightInputFieldView(
            weightString: .constant("75.5"),
            isCompleted: false,
            showWarning: false,
            onWeightChanged: { _ in }
        )
        
        // 완료 상태
        WeightInputFieldView(
            weightString: .constant("80"),
            isCompleted: true,
            showWarning: false,
            onWeightChanged: { _ in }
        )
        
        // 경고 상태
        WeightInputFieldView(
            weightString: .constant(""),
            isCompleted: false,
            showWarning: true,
            onWeightChanged: { _ in }
        )
    }
    .padding()
}
