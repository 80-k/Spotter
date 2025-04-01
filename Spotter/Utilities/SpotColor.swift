//
//  SpotColor.swift
//  Spotter
//
//  Created by woo on 3/30/25.
//

import SwiftUI

// 앱 전체에서 사용할 색상 팔레트
struct SpotColor {
    // 주요 색상 - 테마 통일성을 위해 색상 조정
    static let primary = Color("SpotterPrimaryColor")
    static let secondary = Color("SpotterSecondaryColor")
    
    // 성공/경고/위험 색상 - 다크모드에서 가시성 조정
    static let success = Color("SuccessColor")
    static let warning = Color("WarningColor")
    static let danger = Color("DangerColor")
    
    // 배경 색상
    static let background = Color(UIColor.systemBackground)
    static let secondaryBackground = Color(UIColor.secondarySystemBackground)
    static let tertiaryBackground = Color(UIColor.tertiarySystemBackground)
    
    // 그레이 스케일 - 다크모드 대응 개선
    static let gray1 = Color(UIColor.systemGray6)
    static let gray2 = Color(UIColor.systemGray5)
    static let gray3 = Color(UIColor.systemGray4)
    static let gray4 = Color(UIColor.systemGray3)
    static let gray5 = Color(UIColor.systemGray2)
    static let gray6 = Color(UIColor.systemGray)
    
    // 기능별 색상 - 다크모드 대응 개선
    static let workoutActive = Color("WorkoutActiveColor")
    static let restTimer = Color("RestTimerColor")
    static let completedSet = Color("CompletedSetColor")
    
    // 텍스트 색상
    static let text = Color(UIColor.label)
    static let secondaryText = Color(UIColor.secondaryLabel)
    static let tertiaryText = Color(UIColor.tertiaryLabel)
    
    // 입력 필드 관련 색상
    static let inputBackground = Color("InputBackgroundColor")
    static let inputBorder = Color("InputBorderColor")
    static let inputFocused = Color("InputFocusedColor")
}

// 색상 투명도 확장
extension SpotColor {
    // 주요 색상의 투명도 변환
    static func primary(opacity: Double) -> Color {
        return primary.opacity(opacity)
    }
    
    static func secondary(opacity: Double) -> Color {
        return secondary.opacity(opacity)
    }
    
    static func success(opacity: Double) -> Color {
        return success.opacity(opacity)
    }
    
    static func warning(opacity: Double) -> Color {
        return warning.opacity(opacity)
    }
    
    static func danger(opacity: Double) -> Color {
        return danger.opacity(opacity)
    }
}

// 버튼 스타일
struct PrimaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isDisabled ? SpotColor.gray3 : SpotColor.primary)
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isDisabled ? .gray : SpotColor.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(SpotColor.primary(opacity: 0.1))
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// 테두리가 있는 스타일
struct OutlineButtonStyle: ButtonStyle {
    var isDisabled: Bool = false
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(isDisabled ? .gray : SpotColor.primary)
            .padding()
            .frame(maxWidth: .infinity)
            .background(SpotColor.background)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(isDisabled ? SpotColor.gray2 : SpotColor.primary, lineWidth: 1)
            )
            .cornerRadius(10)
            .scaleEffect(configuration.isPressed ? 0.98 : 1.0)
            .opacity(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.2, dampingFraction: 0.6), value: configuration.isPressed)
    }
}

// 색상 테마 적용을 위한 뷰 확장
extension View {
    func primaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(PrimaryButtonStyle(isDisabled: isDisabled))
    }
    
    func secondaryButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(SecondaryButtonStyle(isDisabled: isDisabled))
    }
    
    func outlineButtonStyle(isDisabled: Bool = false) -> some View {
        self.buttonStyle(OutlineButtonStyle(isDisabled: isDisabled))
    }
    
    // 카드 스타일
    func cardStyle() -> some View {
        self
            .padding()
            .background(SpotColor.background)
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 2)
    }
}
