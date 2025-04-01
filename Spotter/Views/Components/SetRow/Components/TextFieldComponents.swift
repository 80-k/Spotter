// TextFieldComponents.swift
// 입력 필드 관련 공통 컴포넌트
// Created by woo on 3/29/25.

import SwiftUI

// 입력 필드 X 버튼 컴포넌트
struct ClearButton: View {
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Image(systemName: "xmark.circle.fill")
                .foregroundColor(.gray.opacity(0.7))
                .font(.system(size: 14))
        }
    }
}

// 포커스 상태 관리를 위한 뷰 확장
extension View {
    func manageFocus(from internalFocus: FocusState<Bool>.Binding, to externalFocus: Binding<Bool>) -> some View {
        self
            .onChange(of: internalFocus.wrappedValue) { _, newValue in
                externalFocus.wrappedValue = newValue
            }
            .onChange(of: externalFocus.wrappedValue) { _, newValue in
                internalFocus.wrappedValue = newValue
            }
    }
} 