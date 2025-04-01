// SwipeDirection.swift
// 스와이프 방향 열거형
// Created by woo on 4/30/23.

import Foundation

// 스와이프 방향을 나타내는 열거형
enum SwipeDirection {
    case left    // 왼쪽으로 스와이프 (삭제 액션 표시)
    case right   // 오른쪽으로 스와이프 (완료/취소 액션 표시)
    case none    // 스와이프 없음
} 