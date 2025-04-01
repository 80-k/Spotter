// ViewHelpers.swift
// View 확장 및 유틸리티 함수
// Created by woo on 4/30/23.

import SwiftUI

// View에 대한 조건부 수정자 적용을 위한 확장
extension View {
    @ViewBuilder
    func `if`<Transform: View>(_ condition: Bool, transform: (Self) -> Transform) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}
