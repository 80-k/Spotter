// DoubleExtension.swift
// Double 타입 확장 유틸리티
//  Created by woo on 3/29/25.

import Foundation

extension Double {
    // 소수점 자릿수를 제한하는 메서드
    func rounded(toPlaces places: Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
} 