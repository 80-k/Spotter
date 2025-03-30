//
//  LoginView.swift
//  Spotter - 로그인 화면
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct LoginView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    // 상태 관리
    @State private var showingAppleSignIn = false
    @State private var showingGoogleSignIn = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    // 로그인 후 실행할 콜백
    var onLoginCompleted: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 헤더 및 로고
            VStack(spacing: 24) {
                // 로고 이미지 (앱 에셋에 추가 필요)
                Image(systemName: "figure.strengthtraining.traditional")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 80, height: 80)
                    .foregroundColor(.blue)
                    .padding(.top, 40)
                
                // 앱 이름
                Text("Spotter")
                    .font(.system(size: 36, weight: .bold))
                    .foregroundColor(.primary)
                
                // 앱 설명
                Text("당신의 운동을 기록하고 성장을 확인하세요")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
            }
            .frame(maxWidth: .infinity)
            .background(
                Color(.systemBackground)
                    .shadow(color: Color.black.opacity(0.05), radius: 5, y: 3)
            )
            
            Spacer()
            
            // 로그인 섹션
            VStack(spacing: 24) {
                // 안내 문구
                Text("계정 연결")
                    .font(.headline)
                    .padding(.top, 32)
                
                Text("운동 기록을 안전하게 백업하고 여러 기기에서 동기화하려면 계정을 연결하세요.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                
                // 로그인 버튼 그룹
                VStack(spacing: 16) {
                    // Apple 로그인 버튼
                    AppleSignInButton()
                        .padding(.horizontal, 32)
                    
                    // Google 로그인 버튼
                    GoogleSignInButtonAlt()
                        .padding(.horizontal, 32)
                }
                .padding(.vertical, 24)
                
                Spacer()
                
                // 건너뛰기 버튼
                Button("계정 연결 없이 시작하기") {
                    dismiss()
                    onLoginCompleted?()
                }
                .font(.subheadline)
                .foregroundColor(.secondary)
                .padding(.bottom, 32)
            }
        }
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(edges: .top)
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text("로그인 오류"),
                message: Text(alertMessage),
                dismissButton: .default(Text("확인"))
            )
        }
        .onChange(of: authManager.isLoggedIn) { _, isLoggedIn in
            if isLoggedIn {
                // 로그인 성공 시 뷰 닫기 및 콜백 실행
                dismiss()
                onLoginCompleted?()
            }
        }
    }
}

// 온보딩 프로세스에 사용할 수 있는 로그인 화면
struct OnboardingLoginView: View {
    @Binding var hasCompletedOnboarding: Bool
    
    var body: some View {
        LoginView {
            // 로그인 여부와 상관없이 온보딩 완료 처리
            hasCompletedOnboarding = true
        }
    }
}

#Preview {
    LoginView()
}
