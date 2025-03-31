// View+Extensions.swift
// SwiftUI View를 위한 유용한 확장 모음
// Created by woo on 3/31/25.

import SwiftUI

// MARK: - 레이아웃 확장

extension View {
    /// 커스텀 카드 스타일 적용
    func cardStyle(cornerRadius: CGFloat = 12, shadowOpacity: Double = 0.05) -> some View {
        self
            .padding()
            .background(Color(.systemBackground))
            .cornerRadius(cornerRadius)
            .shadow(color: Color.black.opacity(shadowOpacity), radius: 5, x: 0, y: 2)
    }
    
    /// 플로팅 버튼 스타일 적용
    func floatingButtonStyle(backgroundColor: Color = .blue) -> some View {
        self
            .padding()
            .background(backgroundColor)
            .foregroundColor(.white)
            .clipShape(Circle())
            .shadow(color: backgroundColor.opacity(0.4), radius: 5, x: 0, y: 3)
    }
    
    /// 조건부 패딩 적용
    func padding(_ edges: Edge.Set = .all, _ length: CGFloat? = nil, when condition: Bool) -> some View {
        Group {
            if condition {
                self.padding(edges, length)
            } else {
                self
            }
        }
    }
    
    /// 안전 영역 아래로 확장
    func expandToBottomSafeArea() -> some View {
        self
            .ignoresSafeArea(.container, edges: .bottom)
    }
}

// MARK: - 조건부 수정자

extension View {
    /// 조건부 수정자 적용
    @ViewBuilder func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
    
    /// 옵셔널 바인딩 기반 조건부 수정자
    @ViewBuilder func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
    
    /// 조건부 오버레이 적용
    func conditionalOverlay<OverlayContent: View>(
        when condition: Bool,
        @ViewBuilder content: () -> OverlayContent
    ) -> some View {
        self.overlay(condition ? content() : nil)
    }
}

// MARK: - 알림 및 피드백 확장

extension View {
    /// 표준화된 알림창 스타일
    func standardAlert(
        title: String,
        message: String,
        isPresented: Binding<Bool>,
        primaryButton: Alert.Button,
        secondaryButton: Alert.Button? = nil
    ) -> some View {
        if let secondaryButton = secondaryButton {
            return self.alert(isPresented: isPresented) {
                Alert(
                    title: Text(title),
                    message: Text(message),
                    primaryButton: primaryButton,
                    secondaryButton: secondaryButton
                )
            }
        } else {
            return self.alert(isPresented: isPresented) {
                Alert(
                    title: Text(title),
                    message: Text(message),
                    dismissButton: primaryButton
                )
            }
        }
    }
    
    /// 성공, 경고, 오류 알림 톤을 간편하게 추가하는 메서드
    func withFeedback(style: UIImpactFeedbackGenerator.FeedbackStyle = .medium) -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            #if os(iOS)
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.impactOccurred()
            #endif
        })
    }
    
    /// 알림 피드백 (성공/경고/오류)
    func withNotificationFeedback(_ type: UINotificationFeedbackGenerator.FeedbackType) -> some View {
        self.simultaneousGesture(TapGesture().onEnded { _ in
            #if os(iOS)
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(type)
            #endif
        })
    }
}

// MARK: - 애니메이션 확장

extension View {
    /// 반복 펄싱 애니메이션
    func pulsingAnimation(
        enabled: Bool = true,
        duration: Double = 1.5,
        minScale: CGFloat = 0.95,
        maxScale: CGFloat = 1.05
    ) -> some View {
        self.modifier(PulsingAnimationModifier(
            enabled: enabled,
            duration: duration,
            minScale: minScale,
            maxScale: maxScale
        ))
    }
    
    /// 부드러운 등장 애니메이션
    func smoothAppearance(delay: Double = 0) -> some View {
        self
            .opacity(0)
            .offset(y: 20)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(delay)) {
                    _ = self
                        .opacity(1)
                        .offset(y: 0)
                }
            }
    }
}

// MARK: - 애니메이션 모디파이어

struct PulsingAnimationModifier: ViewModifier {
    let enabled: Bool
    let duration: Double
    let minScale: CGFloat
    let maxScale: CGFloat
    
    @State private var isAnimating = false
    
    func body(content: Content) -> some View {
        content
            .scaleEffect(isAnimating ? maxScale : minScale)
            .animation(
                enabled ? Animation.easeInOut(duration: duration).repeatForever(autoreverses: true) : .default,
                value: isAnimating
            )
            .onAppear {
                if enabled {
                    isAnimating = true
                }
            }
    }
}
