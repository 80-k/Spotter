// KeyboardToolbarProvider.swift
// 키보드 툴바 컴포넌트 및 모디파이어
// Created by woo on 3/29/25.

import SwiftUI
import Combine

// 키보드 툴바 버튼 스타일
struct KeyboardToolbarButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .frame(maxWidth: .infinity)
            .padding(.vertical, 8)
            .foregroundColor(configuration.isPressed ? .gray : .white)
            .background(configuration.isPressed ? Color.gray.opacity(0.8) : SpotColor.primary)
            .cornerRadius(8)
    }
}

// 키보드 툴바 제공 뷰 모디파이어
struct KeyboardToolbarModifier: ViewModifier {
    @Binding var isWeightFocused: Bool
    @Binding var isRepsFocused: Bool
    var weightString: String
    var onWeightChanged: (Double) -> Void
    
    func body(content: Content) -> some View {
        content
            .toolbar {
                // 소수점 버튼
                ToolbarItem(placement: .keyboard) {
                    if isWeightFocused && !weightString.contains(".") {
                        Button {
                            // 소수점 추가
                            onWeightChanged(Double("\(weightString).")?.rounded(toPlaces: 2) ?? 0)
                        } label: {
                            Text(".")
                                .font(.title2)
                                .bold()
                        }
                        .buttonStyle(KeyboardToolbarButtonStyle())
                    }
                }
                
                // 비우기 버튼
                ToolbarItem(placement: .keyboard) {
                    if (isWeightFocused && !weightString.isEmpty) || isRepsFocused {
                        Button {
                            if isWeightFocused {
                                onWeightChanged(0)
                            } else {
                                // reps 비우기 콜백
                                NotificationCenter.default.post(
                                    name: NSNotification.Name("ClearRepsField"),
                                    object: nil
                                )
                            }
                        } label: {
                            Text("비우기")
                        }
                        .buttonStyle(KeyboardToolbarButtonStyle())
                    }
                }
                
                // 다음/확인 버튼
                ToolbarItem(placement: .keyboard) {
                    Button {
                        if isWeightFocused {
                            // 무게 입력 시 다음 필드로 포커스 이동
                            isWeightFocused = false
                            isRepsFocused = true
                        } else if isRepsFocused {
                            // 횟수 입력 시 키보드 닫기
                            isRepsFocused = false
                        }
                    } label: {
                        Text(isWeightFocused ? "다음" : "확인")
                    }
                    .buttonStyle(KeyboardToolbarButtonStyle())
                }
            }
    }
}

// 키보드 툴바 뷰 확장
extension View {
    func withKeyboardToolbar(
        weightFocused: Binding<Bool>,
        repsFocused: Binding<Bool>,
        weightString: String,
        onWeightChanged: @escaping (Double) -> Void
    ) -> some View {
        self.modifier(KeyboardToolbarModifier(
            isWeightFocused: weightFocused,
            isRepsFocused: repsFocused,
            weightString: weightString,
            onWeightChanged: onWeightChanged
        ))
    }
} 