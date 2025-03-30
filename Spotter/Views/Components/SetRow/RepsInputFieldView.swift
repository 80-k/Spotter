//
//  RepsInputFieldView.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct RepsInputFieldView: View {
    @Binding var repsString: String
    let isCompleted: Bool
    let showWarning: Bool
    var onRepsChanged: (Int) -> Void
    
    @FocusState private var isFocused: Bool
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("횟수")
                .font(.caption)
                .foregroundColor(.secondary)
            
            HStack(spacing: 4) {
                if isCompleted {
                    // 완료 상태: 텍스트로 표시
                    Text(repsString.isEmpty ? "0" : repsString)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                } else {
                    // 미완료 상태: 입력 필드
                    TextField("0", text: $repsString)
                        .font(.system(size: 16, weight: .medium))
                        .keyboardType(.numberPad)
                        .focused($isFocused)
                        .onChange(of: repsString) { oldValue, newValue in
                            handleRepsChange(newValue)
                        }
                        .frame(width: 40)
                }
                
                Text("회")
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
    
    // 횟수 변경 처리
    private func handleRepsChange(_ newValue: String) {
        // 숫자만 입력 허용
        let validChars = CharacterSet(charactersIn: "0123456789")
        let filtered = String(newValue.unicodeScalars.filter { validChars.contains($0) })
        if filtered != newValue {
            repsString = filtered
            return
        }
        
        // 정수 값으로 변환 가능하면 즉시 업데이트
        if let reps = Int(repsString) {
            onRepsChanged(reps)
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        // 일반 상태
        RepsInputFieldView(
            repsString: .constant("12"),
            isCompleted: false,
            showWarning: false,
            onRepsChanged: { _ in }
        )
        
        // 완료 상태
        RepsInputFieldView(
            repsString: .constant("10"),
            isCompleted: true,
            showWarning: false,
            onRepsChanged: { _ in }
        )
        
        // 경고 상태
        RepsInputFieldView(
            repsString: .constant(""),
            isCompleted: false,
            showWarning: true,
            onRepsChanged: { _ in }
        )
    }
    .padding()
}
