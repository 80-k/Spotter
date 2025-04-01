// SetSelectionManager.swift
// 세트 선택 상태 관리 클래스
// Created by woo on 4/30/23.

import SwiftUI
import Combine
import os
import Foundation

// 로깅을 위한 Logger 설정
private let logger = Logger(subsystem: "com.spotter.app", category: "SetSelectionManager")

// 세트 선택 상태 관리를 위한 ObservableObject
class SetSelectionManager: ObservableObject {
    @Published var selectedSetID: UUID?
    @Published var allowSwipe: Bool = false
    
    // 세트 선택
    func selectSet(_ setID: UUID) {
        selectedSetID = setID
        // 선택 즉시 스와이프 허용으로 전환
        allowSwipe = true
        logger.debug("세트 선택됨: \(setID), 스와이프 허용: \(self.allowSwipe)")
    }
    
    // 선택 해제
    func deselectAll() {
        if self.selectedSetID != nil {
            logger.debug("세트 선택 해제됨, 이전 선택: \(self.selectedSetID!)")
        }
        self.selectedSetID = nil
        allowSwipe = false
    }
    
    // 특정 세트가 선택되었는지 확인
    func isSelected(_ setID: UUID) -> Bool {
        return selectedSetID == setID
    }
} 