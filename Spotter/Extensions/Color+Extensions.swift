// Color+Extensions.swift
// 앱 전체에서 사용할 색상 확장 및 테마
// Created by woo on 3/31/25.

import SwiftUI

// MARK: - 앱 테마 색상

extension Color {
    // 주요 색상
    static let appPrimary = Color.blue
    static let appSecondary = Color.indigo
    
    // 액션/상태 색상
    static let appSuccess = Color.green
    static let appWarning = Color.orange
    static let appError = Color.red
    
    // 기능별 색상
    static let exerciseColor = Color.indigo
    static let setColor = Color.blue
    static let restColor = Color.orange
    static let completedColor = Color.green
    
    // 배경 및 다크모드 지원 색상
    static func appBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(UIColor.systemBackground) : Color.gray.opacity(0.03)
    }
    
    static func appCardBackground(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color(UIColor.secondarySystemBackground) : Color.white
    }
    
    static func appShadow(for colorScheme: ColorScheme) -> Color {
        colorScheme == .dark ? Color.black.opacity(0.1) : Color.black.opacity(0.03)
    }
    
    // 투명도 적용 간편 메서드
    static func primary(opacity: Double) -> Color {
        appPrimary.opacity(opacity)
    }
    
    static func secondary(opacity: Double) -> Color {
        appSecondary.opacity(opacity)
    }
    
    static func success(opacity: Double) -> Color {
        appSuccess.opacity(opacity)
    }
    
    static func warning(opacity: Double) -> Color {
        appWarning.opacity(opacity)
    }
    
    static func error(opacity: Double) -> Color {
        appError.opacity(opacity)
    }
}

// MARK: - 색상 유틸리티

extension Color {
    /// 16진수 코드에서 색상 생성
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
    
    /// 현재 색상의 밝기 조정
    func adjusted(brightness: Double) -> Color {
        let uiColor = UIColor(self)
        var hue: CGFloat = 0
        var saturation: CGFloat = 0
        var brightness: CGFloat = 0
        var alpha: CGFloat = 0
        
        if uiColor.getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            let newBrightness = max(0, min(1, brightness + CGFloat(brightness)))
            return Color(UIColor(hue: hue, saturation: saturation, brightness: newBrightness, alpha: alpha))
        }
        
        return self
    }
    
    /// 색상 밝기 판별
    var isBright: Bool {
        let uiColor = UIColor(self)
        var white: CGFloat = 0
        uiColor.getWhite(&white, alpha: nil)
        return white > 0.5
    }
    
    /// 텍스트 색상 자동 조정 (배경에 따라)
    var appropriateTextColor: Color {
        isBright ? .black : .white
    }
}

// MARK: - 근육 그룹별 색상

extension Color {
    /// 근육 그룹에 따른 색상 반환
    static func forMuscleGroup(_ muscleGroup: String) -> Color {
        switch muscleGroup {
        case MuscleGroup.chest.rawValue:
            return Color.red.opacity(0.7)
        case MuscleGroup.back.rawValue:
            return Color.blue.opacity(0.7)
        case MuscleGroup.legs.rawValue:
            return Color.green.opacity(0.7)
        case MuscleGroup.shoulders.rawValue:
            return Color.orange.opacity(0.7)
        case MuscleGroup.arms.rawValue:
            return Color.purple.opacity(0.7)
        case MuscleGroup.core.rawValue:
            return Color.yellow.opacity(0.7)
        case MuscleGroup.cardio.rawValue:
            return Color.pink.opacity(0.7)
        case MuscleGroup.fullBody.rawValue:
            return Color.indigo.opacity(0.7)
        default:
            return Color.gray.opacity(0.7)
        }
    }
    
    /// 근육 그룹에 따른 배경색 반환 (더 연한 버전)
    static func backgroundForMuscleGroup(_ muscleGroup: String) -> Color {
        switch muscleGroup {
        case MuscleGroup.chest.rawValue:
            return Color.red.opacity(0.1)
        case MuscleGroup.back.rawValue:
            return Color.blue.opacity(0.1)
        case MuscleGroup.legs.rawValue:
            return Color.green.opacity(0.1)
        case MuscleGroup.shoulders.rawValue:
            return Color.orange.opacity(0.1)
        case MuscleGroup.arms.rawValue:
            return Color.purple.opacity(0.1)
        case MuscleGroup.core.rawValue:
            return Color.yellow.opacity(0.1)
        case MuscleGroup.cardio.rawValue:
            return Color.pink.opacity(0.1)
        case MuscleGroup.fullBody.rawValue:
            return Color.indigo.opacity(0.1)
        default:
            return Color.gray.opacity(0.1)
        }
    }
}

// MARK: - 버튼 스타일

extension View {
    /// 기본 버튼 스타일
    func appButtonStyle(isDisabled: Bool = false) -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray : Color.appPrimary)
            .cornerRadius(10)
            .shadow(color: isDisabled ? Color.clear : Color.appPrimary.opacity(0.3), radius: 5, x: 0, y: 3)
    }
    
    /// 세컨더리 버튼 스타일
    func appSecondaryButtonStyle(isDisabled: Bool = false) -> some View {
        self
            .font(.headline)
            .foregroundColor(isDisabled ? .gray : .appPrimary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.appPrimary.opacity(0.1))
            .cornerRadius(10)
    }
    
    /// 아웃라인 버튼 스타일
    func appOutlineButtonStyle(isDisabled: Bool = false) -> some View {
        self
            .font(.headline)
            .foregroundColor(isDisabled ? .gray : .appPrimary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDisabled ? Color.gray : Color.appPrimary, lineWidth: 1)
            )
            .cornerRadius(10)
    }
    
    /// 특정 색상의 버튼 스타일 (성공, 경고, 오류 등)
    func coloredButtonStyle(color: Color, isDisabled: Bool = false) -> some View {
        self
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDisabled ? Color.gray : color)
            .cornerRadius(10)
            .shadow(color: isDisabled ? Color.clear : color.opacity(0.3), radius: 5, x: 0, y: 3)
    }
}
