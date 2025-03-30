// TemplateHeaderView.swift
// 템플릿 상세 화면의 헤더 컴포넌트
// Created by woo on 3/31/25.

import SwiftUI

struct TemplateHeaderView: View {
    let name: String
    let exerciseCount: Int
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(name)
                .font(.largeTitle)
                .fontWeight(.bold)
            
            if exerciseCount > 0 {
                Text("\(exerciseCount)개 운동")
                    .font(.headline)
                    .foregroundColor(.secondary)
            } else {
                Text("운동 없음")
                    .font(.headline)
                    .foregroundColor(.secondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
    }
}

// MARK: - 미리보기

#Preview {
    VStack {
        TemplateHeaderView(
            name: "상체 운동",
            exerciseCount: 5
        )
        
        TemplateHeaderView(
            name: "빈 템플릿",
            exerciseCount: 0
        )
    }
    .previewLayout(.sizeThatFits)
}
