// SearchBarView.swift
// 향상된 검색바 컴포넌트 - 최신 SwiftUI API 적용
// Created by woo on 3/31/25.

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var placeholder: String = "검색"
    var onSubmit: (() -> Void)? = nil
    
    @FocusState private var isFocused: Bool
    @State private var isEditing = false
    
    var body: some View {
        HStack(spacing: 12) {
            // 검색 아이콘과 텍스트 필드
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.secondary)
                    .font(.system(size: 16, weight: .medium))
                
                TextField(placeholder, text: $searchText)
                    .focused($isFocused)
                    .font(.system(.body))
                    .submitLabel(.search)
                    .onSubmit {
                        onSubmit?()
                    }
                    .onChange(of: isFocused) { _, newValue in
                        withAnimation {
                            isEditing = newValue
                        }
                    }
                
                // 취소 버튼 (텍스트가 있을 때만)
                if !searchText.isEmpty {
                    Button(action: {
                        searchText = ""
                    }) {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16))
                    }
                    .transition(.opacity)
                    .animation(.easeInOut(duration: 0.2), value: searchText)
                }
            }
            .padding(10)
            .background(
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(.systemGray6))
            )
            
            // 취소 버튼 (편집 중일 때만)
            if isEditing {
                Button("취소") {
                    searchText = ""
                    isFocused = false
                }
                .foregroundColor(.accentColor)
                .transition(.move(edge: .trailing).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.2), value: isEditing)
            }
        }
    }
}

// MARK: - 미리보기

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 20) {
        SearchBarView(searchText: .constant(""))
        
        SearchBarView(searchText: .constant("덤벨"), placeholder: "운동 이름 검색")
        
        SearchBarView(searchText: .constant("벤치"), placeholder: "장비 검색", onSubmit: {
            print("검색 제출!")
        })
    }
    .padding()
} 