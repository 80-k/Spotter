// DraggableRowView.swift
// 드래그 가능한 세트 행 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData

struct DraggableRowView<Content: View>: View {
    @Binding var sets: [WorkoutSet]
    var set: WorkoutSet
    var index: Int
    var content: Content
    var modelContext: ModelContext
    var backgroundTint: Color
    
    // 드래그 상태 관리
    @Binding var draggingItem: WorkoutSet?
    @Binding var draggingOffset: CGFloat
    var itemHeight: CGFloat
    
    init(
        sets: Binding<[WorkoutSet]>,
        set: WorkoutSet,
        at index: Int,
        draggingItem: Binding<WorkoutSet?>,
        draggingOffset: Binding<CGFloat>,
        itemHeight: CGFloat,
        modelContext: ModelContext,
        backgroundTint: Color = .clear,
        @ViewBuilder content: () -> Content
    ) {
        self._sets = sets
        self.set = set
        self.index = index
        self._draggingItem = draggingItem
        self._draggingOffset = draggingOffset
        self.itemHeight = itemHeight
        self.modelContext = modelContext
        self.backgroundTint = backgroundTint
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            // 배경
            Rectangle()
                .fill(draggingItem?.id == set.id ? Color(.systemGray6).opacity(0.8) : backgroundTint)
            
            // 드래그 핸들
            DragHandleView()
            
            // 콘텐츠
            content
        }
        .frame(height: itemHeight)
        .contentShape(Rectangle())
        .offset(y: draggingItem?.id == set.id ? draggingOffset : 0)
        .zIndex(draggingItem?.id == set.id ? 1 : 0)
        // 드래그 제스처
        .simultaneousGesture(
            LongPressGesture(minimumDuration: 0.3)
                .sequenced(before: DragGesture(minimumDistance: 0))
                .onChanged { value in
                    switch value {
                    case .first(true):
                        // 롱프레스 시작 시 효과
                        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                        impactFeedback.impactOccurred()
                    case .second(true, let dragValue?):
                        // 옵셔널 드래그 값을 unwrap하여 사용
                        handleDragChange(dragValue)
                    default:
                        break
                    }
                }
                .onEnded { _ in
                    handleDragEnd()
                }
        )
    }
    
    // 드래그 변경 처리
    private func handleDragChange(_ value: DragGesture.Value) {
        if draggingItem == nil {
            draggingItem = set
            draggingOffset = value.translation.height
        } else if draggingItem?.id == set.id {
            draggingOffset = value.translation.height
            
            // 위치 계산하여 필요시 항목 이동
            let newIndex = max(0, min(sets.count - 1, 
                               index + Int(draggingOffset / itemHeight)))
            
            if newIndex != index {
                // 항목 이동
                withAnimation(.linear(duration: 0.2)) {
                    let item = sets.remove(at: index)
                    sets.insert(item, at: newIndex)
                    draggingOffset = 0
                }
                
                // order 속성 업데이트
                updateSetsOrder(sets, in: modelContext)
            }
        }
    }
    
    // 드래그 종료 처리
    private func handleDragEnd() {
        // 완료 후 order 속성 업데이트
        updateSetsOrder(sets, in: modelContext)
        
        // 드래그 상태 초기화
        withAnimation(.spring()) {
            draggingItem = nil
            draggingOffset = 0
        }
    }
} 