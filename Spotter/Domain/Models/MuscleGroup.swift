// MuscleGroup.swift
// 운동 부위 분류 열거형
//  Created by woo on 3/29/25.

import Foundation

/// 운동 부위 분류
enum MuscleGroup: String, CaseIterable, Codable {
    case chest = "가슴"
    case back = "등"
    case legs = "하체"
    case shoulders = "어깨"
    case arms = "팔"
    case core = "코어"
    case cardio = "유산소"
    case fullBody = "전신"
    
    /// 부위에 따른 아이콘 이름
    var iconName: String {
        switch self {
        case .chest: return "figure.strengthtraining.traditional"
        case .back: return "figure.strengthtraining.traditional"
        case .legs: return "figure.walk"
        case .shoulders: return "figure.mind.and.body"
        case .arms: return "figure.boxing"
        case .core: return "figure.core.training"
        case .cardio: return "figure.run"
        case .fullBody: return "figure.highintensity.intervaltraining"
        }
    }
} 