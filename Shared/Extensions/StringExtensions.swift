// StringExtensions.swift
// String 관련 확장 메서드 모음
// Created by woo on 4/30/23.

import Foundation

// UUID 변환을 위한 확장
extension String {
    func toUUID() -> UUID? {
        return UUID(uuidString: self)
    }
} 