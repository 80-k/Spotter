// SetListUtils.swift
// 세트 목록 관련 유틸리티 함수들
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData
import os

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "SetListUtils")

// 세트 행 배경색 계산 함수
func getRowBackground(for set: WorkoutSet, at index: Int, isDragging: Bool) -> Color {
    let bgColor: Color
    let opacity: Double
    
    if isDragging {
        bgColor = Color(.systemGray6)
        opacity = 0.8
    } else if index % 2 == 0 {
        bgColor = Color(.systemBackground)
        opacity = 0.4
    } else {
        bgColor = Color.clear
        opacity = 0
    }
    
    return bgColor.opacity(opacity)
}

// 드래그 핸들 오버레이 가져오기
struct DragHandleView: View {
    var body: some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            Spacer()
        }
    }
}

// 세트 순서 업데이트 헬퍼
func updateSetsOrder(_ sets: [WorkoutSet], in modelContext: ModelContext) {
    for (idx, setItem) in sets.enumerated() {
        setItem.order = idx + 1
    }
    
    // 변경 사항 저장
    do {
        try modelContext.save()
    } catch {
        logger.error("세트 순서 업데이트 중 오류 발생: \(error.localizedDescription)")
    }
} 