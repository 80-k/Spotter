// SyncEnums.swift
// 동기화 관련 열거형 정의
// Created by woo on 3/30/25.

import Foundation

// 동기화 상태 열거형
enum SyncStatus {
    case idle        // 대기 중
    case syncing     // 동기화 중
    case completed   // 완료됨
    case failed      // 실패
    case offline     // 오프라인
}
