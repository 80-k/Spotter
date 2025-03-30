// AuthManager.swift
// 통합 인증 관리 클래스 (Apple 및 Google 로그인)
// Created by woo on 3/30/25.

import SwiftUI
import Combine

// 로그인 제공자 유형
enum AuthProvider: String, CaseIterable {
    case none = "없음"
    case apple = "Apple"
    case google = "Google"
}

// 통합 인증 관리 클래스
class AuthManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = AuthManager()
    
    // 현재 인증 상태
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var profileImageURL: URL? = nil
    @Published var authProvider: AuthProvider = .none
    
    // 개별 인증 관리자
    private let appleSignInManager = AppleSignInManager.shared
    private let googleSignInManager = GoogleSignInManager.shared
    
    // 구독 저장소
    private var cancellables = Set<AnyCancellable>()
    
    private init() {
        // 개별 인증 관리자 상태 변화 감지
        setupSubscriptions()
        
        // 저장된 인증 정보 불러오기
        loadAuthState()
        
        // 인증 제공자 복원
        restoreAuthProvider()
    }
    
    // MARK: - 공개 메서드
    
    // 로그아웃
    func signOut() {
        // 현재 사용 중인 인증 제공자로 로그아웃
        switch authProvider {
        case .apple:
            appleSignInManager.signOut()
        case .google:
            googleSignInManager.signOut()
        case .none:
            break
        }
        
        // 상태 초기화
        isLoggedIn = false
        userName = ""
        userEmail = ""
        profileImageURL = nil
        authProvider = .none
        
        // 상태 저장
        saveAuthState()
    }
    
    // MARK: - 내부 메서드
    
    // 개별 로그인 관리자 상태 변화 구독
    private func setupSubscriptions() {
        // Apple 로그인 상태 변경 감지
        appleSignInManager.$isLoggedIn
            .combineLatest(
                appleSignInManager.$userName,
                appleSignInManager.$userEmail
            )
            .sink { [weak self] isLoggedIn, name, email in
                guard let self = self else { return }
                
                if isLoggedIn {
                    self.isLoggedIn = true
                    self.userName = name
                    self.userEmail = email
                    self.profileImageURL = nil
                    self.authProvider = .apple
                    self.saveAuthState()
                }
            }
            .store(in: &cancellables)
        
        // Google 로그인 상태 변경 감지
        googleSignInManager.$isLoggedIn
            .combineLatest(
                googleSignInManager.$userName,
                googleSignInManager.$userEmail,
                googleSignInManager.$userProfilePictureURL
            )
            .sink { [weak self] isLoggedIn, name, email, profileURL in
                guard let self = self else { return }
                
                if isLoggedIn {
                    self.isLoggedIn = true
                    self.userName = name
                    self.userEmail = email
                    self.profileImageURL = profileURL
                    self.authProvider = .google
                    self.saveAuthState()
                }
            }
            .store(in: &cancellables)
    }
    
    // 인증 상태 저장
    private func saveAuthState() {
        UserDefaults.standard.set(isLoggedIn, forKey: "auth_is_logged_in")
        UserDefaults.standard.set(userName, forKey: "auth_user_name")
        UserDefaults.standard.set(userEmail, forKey: "auth_user_email")
        UserDefaults.standard.set(authProvider.rawValue, forKey: "auth_provider")
        
        if let profileURL = profileImageURL {
            UserDefaults.standard.set(profileURL.absoluteString, forKey: "auth_profile_image_url")
        } else {
            UserDefaults.standard.removeObject(forKey: "auth_profile_image_url")
        }
    }
    
    // 인증 상태 불러오기
    private func loadAuthState() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "auth_is_logged_in")
        userName = UserDefaults.standard.string(forKey: "auth_user_name") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "auth_user_email") ?? ""
        
        if let providerString = UserDefaults.standard.string(forKey: "auth_provider"),
           let provider = AuthProvider(rawValue: providerString) {
            authProvider = provider
        } else {
            authProvider = .none
        }
        
        if let urlString = UserDefaults.standard.string(forKey: "auth_profile_image_url") {
            profileImageURL = URL(string: urlString)
        }
    }
    
    // 인증 제공자 복원
    private func restoreAuthProvider() {
        // 저장된 인증 제공자가 없으면 건너뜀
        guard authProvider != .none, isLoggedIn else {
            return
        }
        
        // 인증 제공자 복원 시도
        switch authProvider {
        case .apple:
            // 애플 인증은 자동 복원이 덜 신뢰할 수 있음
            // 실제 연결 상태 확인 필요 시 추가 로직 구현
            break
            
        case .google:
            // Google 자동 로그인 시도는 GoogleSignInManager에서 이미 처리함
            break
            
        case .none:
            break
        }
    }
}

// 프로필 이미지 비동기 로드를 위한 뷰
struct ProfileImageView: View {
    let imageURL: URL?
    let placeholderImage: String
    var size: CGFloat = 40
    
    var body: some View {
        if let url = imageURL {
            AsyncImage(url: url) { phase in
                switch phase {
                case .empty:
                    ProgressView()
                        .frame(width: size, height: size)
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFill()
                        .frame(width: size, height: size)
                        .clipShape(Circle())
                case .failure:
                    Image(systemName: placeholderImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.6, height: size * 0.6)
                        .frame(width: size, height: size)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                @unknown default:
                    Image(systemName: placeholderImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: size * 0.6, height: size * 0.6)
                        .frame(width: size, height: size)
                        .background(Color.gray.opacity(0.1))
                        .clipShape(Circle())
                }
            }
        } else {
            Image(systemName: placeholderImage)
                .resizable()
                .scaledToFit()
                .frame(width: size * 0.6, height: size * 0.6)
                .frame(width: size, height: size)
                .background(Color.gray.opacity(0.1))
                .clipShape(Circle())
        }
    }
}

// 통합 인증 버튼 컨테이너
struct AuthButtonsView: View {
    @ObservedObject var authManager = AuthManager.shared
    @ObservedObject var appleSignInManager = AppleSignInManager.shared
    @ObservedObject var googleSignInManager = GoogleSignInManager.shared
    
    var body: some View {
        VStack(spacing: 16) {
            // 안내 문구
            Text("계정 연결")
                .font(.headline)
                .padding(.bottom, 4)
            
            Text("운동 기록을 안전하게 백업하고 여러 기기에서 동기화하려면 계정을 연결하세요.")
                .font(.caption)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .padding(.bottom, 8)
            
            // Apple 로그인 버튼
            AppleSignInButton()
            
            // Google 로그인 버튼
            GoogleSignInButtonAlt()
            
            // 건너뛰기 버튼
            Button("나중에 하기") {
                // 건너뛰기 액션 (예: 로그인 화면 닫기)
            }
            .font(.caption)
            .foregroundColor(.secondary)
            .padding(.top, 8)
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(16)
    }
}
