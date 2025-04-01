// StaticSetListView.swift
// 일반 모드의 정적 세트 목록 뷰 컴포넌트
// Created by woo on 4/30/23.

import SwiftUI
import os
import SwiftData
import Foundation

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "StaticSetListView")

// 일반 모드에서 사용하는 정적 세트 목록 뷰
struct StaticSetListView: View {
    @Binding var sets: [WorkoutSet]
    var viewModel: ActiveWorkoutViewModel
    var exercise: ExerciseItem
    var isActive: Bool
    
    // 세트 선택 상태 관리
    @StateObject private var selectionManager = SetSelectionManager()
    
    var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(sets.enumerated()), id: \.element.id) { index, set in
                setRowView(for: set, at: index)
            }
        }
        // 리스트 외부 탭 시 강조 상태 해제
        .onTapGesture {
            if selectionManager.selectedSetID != nil {
                logger.debug("리스트 외부 탭됨, 강조 해제 (정적 모드)")
                selectionManager.deselectAll()
            }
        }
    }
    
    // 세트 행 뷰를 별도 메서드로 분리
    private func setRowView(for set: WorkoutSet, at index: Int) -> some View {
        // 현재 세트가 강조 상태인지 확인 - 복잡한 표현식을 분리
        let setUUID = generateUUIDFromID(set.id)
        let isHighlighted = selectionManager.isSelected(setUUID)
        
        // 바인딩 생성
        let isSetHighlighted = createHighlightBinding(isHighlighted: isHighlighted, setUUID: setUUID, index: index)
        
        return StaticRowView(
            set: set,
            at: index,
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
                    logger.debug("세트 \(index+1) 삭제 콜백 호출됨 (정적 모드)")
                    viewModel.deleteSet(set)
                },
                disableCompleteButton: !isActive && viewModel.isAnotherExerciseActive(exercise),
                isHighlighted: isSetHighlighted,
                selectedSetID: $selectionManager.selectedSetID
            )
            .padding(.vertical, 4)
            .padding(.horizontal, 12)
        }
        // 새로운 커스텀 스와이프 액션 적용 - 복잡한 표현식 분리
        .withCustomSwipeActions(
            set: set,
            onDelete: { 
                logger.debug("세트 \(index+1) 삭제 액션 실행 (정적 모드)")
                viewModel.deleteSet(set)
                selectionManager.deselectAll()
            },
            onToggleCompletion: { 
                logger.debug("세트 \(index+1) 완료 토글 액션 실행 (정적 모드)")
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
        // 세트 선택 해제 처리
        .onTapGesture {
            if selectionManager.selectedSetID != nil {
                logger.debug("세트 \(index+1)의 영역 탭됨, 강조 해제 (정적 모드)")
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
                    logger.debug("세트 \(index+1) 강조 상태 활성화 (정적 모드)")
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