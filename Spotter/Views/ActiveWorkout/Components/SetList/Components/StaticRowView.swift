// StaticRowView.swift
// 정적 세트 행 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI

struct StaticRowView<Content: View>: View {
    var set: WorkoutSet
    var index: Int
    var backgroundTint: Color
    var content: Content
    
    init(
        set: WorkoutSet,
        at index: Int,
        backgroundTint: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self.set = set
        self.index = index
        self.backgroundTint = backgroundTint
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 배경
            Rectangle()
                .fill(backgroundTint)
            
            // 콘텐츠
            content
        }
        .contentShape(Rectangle())
    }
} 