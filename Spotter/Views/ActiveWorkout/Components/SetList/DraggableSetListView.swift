// DraggableSetListView.swift
// 드래그 가능한 세트 목록 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import SwiftData
import os
import Foundation

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "DraggableSetListView")

// 드래그 가능한 세트 목록 뷰
struct DraggableSetListView: View {
    @Binding var sets: [WorkoutSet]
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    var isActive: Bool
    
    // 세트 선택 상태 관리
    @StateObject private var selectionManager = SetSelectionManager()
    
    // 드래그 상태 관리
    @State private var draggingItem: WorkoutSet?
    @State private var draggingOffset: CGFloat = 0
    @State private var itemHeight: CGFloat = 60
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                setRowView(for: set, at: index)
            }
        }
        // 배경 영역 탭 시 강조 상태 해제
        .onTapGesture {
            if selectionManager.selectedSetID != nil {
                logger.debug("리스트 외부 탭됨, 강조 해제 (드래그 모드)")
                selectionManager.deselectAll()
            }
        }
        // 드래그 완료 시 세트 순서 저장
        .onChange(of: draggingItem) { _, newValue in
            if newValue == nil && !sets.isEmpty {
                logger.debug("드래그 완료: 세트 순서 업데이트")
                // 세트 순서 저장
                updateSetsOrder(sets, in: viewModel.modelContext)
            }
        }
        // 뷰가 나타날 때 초기화
        .onAppear {
            // 높이 계산
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                itemHeight = 80 // 대략적인 높이 설정
            }
        }
    }
    
    // 세트 행 뷰를 별도 메서드로 분리
    private func setRowView(for set: WorkoutSet, at index: Int) -> some View {
        // 복잡한 표현식 분리
        let setUUID = generateUUIDFromID(set.id)
        let isHighlighted = selectionManager.isSelected(setUUID)
        
        // 현재 세트가 강조 상태인지 확인
        let isSetHighlighted = createHighlightBinding(isHighlighted: isHighlighted, setUUID: setUUID, index: index)
        
        return DraggableRowView(
            sets: $sets,
            set: set,
            at: index,
            draggingItem: $draggingItem,
            draggingOffset: $draggingOffset,
            itemHeight: itemHeight,
            modelContext: viewModel.modelContext,
            backgroundTint: index % 2 == 0 ? Color(.systemGray6).opacity(0.3) : Color.clear
        ) {
            ExerciseSetRowView(
                set: set,
                setNumber: index + 1,
                onWeightChanged: { weight in
                    viewModel.updateSet(set, weight: weight)
                },
                onRepsChanged: { reps in
                    viewModel.updateSet(set, reps: reps)
                },
                onCompleteToggle: {
                    viewModel.toggleSetCompletion(set)
                },
                onDelete: {
                    logger.debug("세트 \(index+1) 삭제 콜백 호출됨 (드래그 모드)")
                    viewModel.deleteSet(set)
                },
                disableCompleteButton: !isActive && viewModel.isAnotherExerciseActive(exercise),
                isHighlighted: isSetHighlighted,
                selectedSetID: $selectionManager.selectedSetID
            )
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
        }
        // 새로운 커스텀 스와이프 액션 적용
        .withCustomSwipeActions(
            set: set,
            onDelete: { 
                logger.debug("세트 \(index+1) 삭제 액션 실행 (드래그 모드)")
                viewModel.deleteSet(set)
                selectionManager.deselectAll()
            },
            onToggleCompletion: { 
                logger.debug("세트 \(index+1) 완료 토글 액션 실행 (드래그 모드)")
                viewModel.toggleSetCompletion(set)
                selectionManager.deselectAll()
            },
            isHighlighted: isHighlighted
        )
        .allowsHitTesting(true)
        .overlay(
            Divider()
                .opacity(index < sets.count - 1 ? 1 : 0)
                .padding(.horizontal, 10),
            alignment: .bottom
        )
        // 드래그 제스처 수신 시 강조 상태 해제
        .onTapGesture {
            if selectionManager.selectedSetID != nil {
                logger.debug("세트 \(index+1)의 영역 탭됨, 강조 해제 (드래그 모드)")
                selectionManager.deselectAll()
            }
        }
    }
    
    // 강조 표시 바인딩 생성 메서드 - 복잡한 표현식 분리
    private func createHighlightBinding(isHighlighted: Bool, setUUID: UUID, index: Int) -> Binding<Bool> {
        return Binding<Bool>(
            get: { isHighlighted },
            set: { newValue in
                if newValue {
                    selectionManager.selectSet(setUUID)
                    logger.debug("세트 \(index+1) 강조 상태 활성화 (드래그 모드)")
                } else {
                    selectionManager.deselectAll()
                }
            }
        )
    }
    
    // PersistentIdentifier를 UUID로 변환
    private func generateUUIDFromID(_ id: PersistentIdentifier) -> UUID {
        // PersistentIdentifier를 문자열로 변환하고 해시값으로 UUID 생성
        let idString = String(describing: id)
        return UUID(uuidString: idString) ?? UUID()
    }
} 