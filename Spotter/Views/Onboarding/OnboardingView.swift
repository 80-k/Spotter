//
//  OnboardingView.swift
//  Spotter - 온보딩 화면
//
//  Created by woo on 3/30/25.
//

import SwiftUI

// 온보딩 페이지 데이터 구조체
struct OnboardingPage {
    let image: String  // SF Symbol 이름
    let title: String
    let description: String
}

struct OnboardingView: View {
    // 이 바인딩을 통해 온보딩 완료 여부를 전달
    @Binding var hasCompletedOnboarding: Bool
    
    // 현재 페이지 인덱스
    @State private var currentPage = 0
    
    // 온보딩 페이지 데이터
    let pages: [OnboardingPage] = [
        OnboardingPage(
            image: "figure.strengthtraining.traditional",
            title: "운동 기록 추적",
            description: "세트, 무게, 반복 횟수를 쉽게 기록하고 진행 상황을 추적하세요."
        ),
        OnboardingPage(
            image: "timer",
            title: "휴식 타이머",
            description: "세트 간 최적의 휴식 시간을 관리하여 운동 효율을 높이세요."
        ),
        OnboardingPage(
            image: "chart.xyaxis.line",
            title: "성장 분석",
            description: "시간에 따른 성장을 그래프로 확인하고 목표를 설정하세요."
        ),
        OnboardingPage(
            image: "icloud",
            title: "클라우드 동기화",
            description: "계정을 연결하여 모든 기기에서 운동 기록을 동기화하세요."
        )
    ]
    
    var body: some View {
        ZStack {
            // 배경색
            Color(.systemBackground)
                .ignoresSafeArea()
            
            // 마지막 페이지(로그인)인 경우
            if currentPage == pages.count {
                OnboardingLoginView(hasCompletedOnboarding: $hasCompletedOnboarding)
            } else {
                // 일반 온보딩 페이지
                VStack(spacing: 0) {
                    // 건너뛰기 버튼
                    HStack {
                        Spacer()
                        
                        Button("건너뛰기") {
                            withAnimation {
                                currentPage = pages.count // 로그인 페이지로 이동
                            }
                        }
                        .padding()
                        .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    // 현재 페이지 콘텐츠
                    TabView(selection: $currentPage) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            PageView(page: pages[index])
                                .tag(index)
                        }
                    }
                    .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
                    .indexViewStyle(PageIndexViewStyle(backgroundDisplayMode: .always))
                    
                    Spacer()
                    
                    // 하단 버튼
                    Button(action: {
                        withAnimation {
                            if currentPage < pages.count {
                                currentPage += 1
                            }
                        }
                    }) {
                        HStack {
                            Text("다음")
                                .font(.headline)
                                .foregroundColor(.white)
                            
                            Image(systemName: "chevron.right")
                                .font(.headline)
                                .foregroundColor(.white)
                        }
                        .frame(minWidth: 150)
                        .padding()
                        .background(Color.blue)
                        .cornerRadius(10)
                    }
                    .padding(.bottom, 50)
                }
                .transition(.opacity)
            }
        }
    }
}

// 개별 온보딩 페이지 뷰
struct PageView: View {
    let page: OnboardingPage
    
    var body: some View {
        VStack(spacing: 32) {
            Image(systemName: page.image)
                .resizable()
                .scaledToFit()
                .frame(width: 150, height: 150)
                .foregroundColor(.blue)
                .padding(.bottom, 16)
            
            Text(page.title)
                .font(.system(size: 32, weight: .bold))
                .padding(.horizontal)
            
            Text(page.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
                .padding(.horizontal, 32)
        }
        .padding()
    }
}

struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView(hasCompletedOnboarding: .constant(false))
    }
}
