// SearchBarView.swift
// 검색 바 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    
    var body: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(.gray)
            
            TextField("운동 이름 검색", text: $searchText)
                .textFieldStyle(PlainTextFieldStyle())
                .autocorrectionDisabled()
                .textInputAutocapitalization(.never)
            
            if !searchText.isEmpty {
                Button(action: {
                    searchText = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
            }
        }
        .padding(8)
        .background(Color(.systemGray6))
        .cornerRadius(10)
    }
}

// MARK: - 미리보기

#Preview {
    struct PreviewWrapper: View {
        @State private var searchText = ""
        @State private var searchTextWithValue = "벤치 프레스"
        
        var body: some View {
            VStack(spacing: 20) {
                // 빈 검색어
                SearchBarView(searchText: $searchText)
                
                // 검색어가 있는 경우
                SearchBarView(searchText: $searchTextWithValue)
            }
            .padding()
        }
    }
    
    return PreviewWrapper()
}
