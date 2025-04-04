// DraggableSetList.swift
// 드래그로 순서 변경이 가능한 세트 목록 컴포넌트
// Created by woo on 3/29/25.

import SwiftUI

struct DraggableSetList: View {
    @Binding var sets: [WorkoutSet]
    let exercise: ExerciseItem
    let isActive: Bool
    var onReorder: ([WorkoutSet]) -> Void
    
    // 기존 콜백 함수들
    var onWeightChanged: (WorkoutSet, Double) -> Void
    var onRepsChanged: (WorkoutSet, Int) -> Void
    var onCompleteToggle: (WorkoutSet) -> Void
    var onDelete: (WorkoutSet) -> Void
    
    // 드래그 상태 관리
    @State private var draggingItem: WorkoutSet?
    @State private var draggingOffset: CGFloat = 0
    @State private var itemHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                ExerciseSetRowView(
                    set: set,
                    setNumber: index + 1,
                    onWeightChanged: { weight in
                        onWeightChanged(set, weight)
                    },
                    onRepsChanged: { reps in
                        onRepsChanged(set, reps)
                    },
                    onCompleteToggle: {
                        onCompleteToggle(set)
                    },
                    onDelete: {
                        onDelete(set)
                    },
                    disableCompleteButton: !isActive
                )
                .padding(.vertical, 4)
                .padding(.horizontal, 12)
                .background(getRowBackground(for: set, at: index))
                .contentShape(Rectangle())
                .offset(y: draggingItem?.id == set.id ? draggingOffset : 0)
                .zIndex(draggingItem?.id == set.id ? 1 : 0)
                .overlay(getDragHandleOverlay())
                .overlay(
                    Divider()
                        .opacity(index < sets.count - 1 ? 1 : 0)
                        .padding(.horizontal, 10),
                    alignment: .bottom
                )
                .gesture(
                    DragGesture()
                        .onChanged { handleDragChange(value: $0, set: set, currentIndex: index) }
                        .onEnded { _ in handleDragEnd() }
                )
                .onAppear {
                    // 적절한 높이 측정
                    DispatchQueue.main.async {
                        itemHeight = 60 // 항목 높이 설정
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Methods
    
    // 행 배경 가져오기
    private func getRowBackground(for set: WorkoutSet, at index: Int) -> some View {
        let bgColor: Color
        if draggingItem?.id == set.id {
            bgColor = Color(.systemGray6)
        } else if index % 2 == 0 {
            bgColor = Color(.systemBackground)
        } else {
            bgColor = Color.clear
        }
        
        let opacity: Double
        if draggingItem?.id == set.id {
            opacity = 0.8
        } else if index % 2 == 0 {
            opacity = 0.4
        } else {
            opacity = 0
        }
        
        return bgColor.opacity(opacity)
    }
    
    // 드래그 핸들 오버레이 가져오기
    private func getDragHandleOverlay() -> some View {
        HStack {
            Image(systemName: "line.3.horizontal")
                .foregroundColor(.gray)
                .padding(.leading, 8)
            Spacer()
        }
    }
    
    // 드래그 변경 처리
    private func handleDragChange(value: DragGesture.Value, set: WorkoutSet, currentIndex: Int) {
        if draggingItem == nil {
            draggingItem = set
            draggingOffset = value.translation.height
        } else if draggingItem?.id == set.id {
            draggingOffset = value.translation.height
            
            // 위치 계산하여 필요시 항목 이동
            let newIndex = max(0, min(sets.count - 1, 
                                   currentIndex + Int(draggingOffset / itemHeight)))
            
            if newIndex != currentIndex {
                // 항목 이동
                withAnimation(.linear(duration: 0.2)) {
                    let item = sets.remove(at: currentIndex)
                    sets.insert(item, at: newIndex)
                    draggingOffset = 0
                }
                
                // order 속성 업데이트 및 콜백 호출
                updateSetsOrder()
            }
        }
    }
    
    // 드래그 종료 처리
    private func handleDragEnd() {
        // 완료 후 order 속성 업데이트 및 콜백 호출
        updateSetsOrder()
        
        // 드래그 상태 초기화
        withAnimation(.spring()) {
            draggingItem = nil
            draggingOffset = 0
        }
    }
    
    // 세트 순서 업데이트
    private func updateSetsOrder() {
        // 순서 업데이트
        for (idx, setItem) in sets.enumerated() {
            setItem.order = idx + 1
        }
        
        // 순서 변경 콜백 호출
        onReorder(sets)
    }
}

// UUID 문자열 변환 확장
extension UUID {
    var stringValue: String {
        return self.uuidString
    }
} 