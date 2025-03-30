// GoogleSignInManager.swift
// Google ID 로그인 관리
// Created by woo on 3/30/25.

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

// Google 로그인 관리 클래스
class GoogleSignInManager: ObservableObject {
    // 싱글톤 인스턴스
    static let shared = GoogleSignInManager()
    
    // 현재 로그인 상태
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var userProfilePictureURL: URL? = nil
    
    // 로그인 중 상태
    @Published var isLoggingIn: Bool = false
    
    private init() {
        // 저장된 로그인 상태 불러오기
        loadLoginState()
        
        // 앱 시작 시 이전 로그인 세션 복원 시도
        restorePreviousSignIn()
    }
    
    // MARK: - 공개 메서드
    
    // 자동 로그인 시도 (앱 시작 시)
    private func restorePreviousSignIn() {
        GIDSignIn.sharedInstance.restorePreviousSignIn { [weak self] gidUser, error in
            guard let self = self else { return }
            
            if let error = error {
                print("자동 로그인 오류: \(error.localizedDescription)")
                return
            }
            
            // 사용자 정보 업데이트
            self.handleSignInResult(user: gidUser)
        }
    }
    
    // 로그인 요청 - UIKit 방식 (직접 호출하지 않음)
    func signIn(with viewController: UIViewController, completion: @escaping (Bool, Error?) -> Void) {
        isLoggingIn = true
        
        // Google 로그인 설정
        guard let clientID = googleClientID else {
            completion(false, NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "클라이언트 ID가 없습니다"]))
            return
        }
        
        let signInConfig = GIDConfiguration(clientID: clientID)
        
        // 로그인 창 표시
        GIDSignIn.sharedInstance.signIn(
            with: signInConfig,
            presenting: viewController
        ) { [weak self] gidUser, error in
            guard let self = self else { return }
            self.isLoggingIn = false
            
            if let error = error {
                print("Google 로그인 오류: \(error.localizedDescription)")
                completion(false, error)
                return
            }
            
            // 사용자 정보 업데이트
            self.handleSignInResult(user: gidUser)
            completion(true, nil)
        }
    }
    
    // SwiftUI에서 사용하기 위한 로그인 메서드
    func signIn(completion: @escaping (Bool, Error?) -> Void) {
        // 루트 뷰 컨트롤러 가져오기 (iOS 15+ 방식)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootVC = scene.windows.first?.rootViewController {
            signIn(with: rootVC, completion: completion)
        } else {
            completion(false, NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "루트 뷰 컨트롤러를 찾을 수 없습니다."]))
        }
    }
    
    // 로그아웃
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        
        isLoggedIn = false
        userName = ""
        userEmail = ""
        userProfilePictureURL = nil
        
        saveLoginState()
    }
    
    // MARK: - 내부 메서드
    
    // 로그인 결과 처리
    private func handleSignInResult(user: GIDGoogleUser?) {
        guard let user = user else {
            isLoggedIn = false
            saveLoginState()
            return
        }
        
        // 사용자 정보 추출
        if let profile = user.profile {
            userName = profile.name
            userEmail = profile.email
            userProfilePictureURL = profile.imageURL(withDimension: 100)
        }
        
        // 로그인 상태 업데이트 및 저장
        isLoggedIn = true
        saveLoginState()
    }
    
    // 로그인 상태 저장
    private func saveLoginState() {
        UserDefaults.standard.set(isLoggedIn, forKey: "google_signin_logged_in")
        UserDefaults.standard.set(userName, forKey: "google_signin_user_name")
        UserDefaults.standard.set(userEmail, forKey: "google_signin_user_email")
        if let profileURL = userProfilePictureURL {
            UserDefaults.standard.set(profileURL.absoluteString, forKey: "google_signin_profile_url")
        } else {
            UserDefaults.standard.removeObject(forKey: "google_signin_profile_url")
        }
    }
    
    // 로그인 상태 불러오기
    private func loadLoginState() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "google_signin_logged_in")
        userName = UserDefaults.standard.string(forKey: "google_signin_user_name") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "google_signin_user_email") ?? ""
        if let urlString = UserDefaults.standard.string(forKey: "google_signin_profile_url") {
            userProfilePictureURL = URL(string: urlString)
        }
    }
    
    // MARK: - 설정 값
    
    // Google 클라이언트 ID
    private var googleClientID: String? {
        // Info.plist에서 값을 가져오거나, 환경 변수로 설정
        return Bundle.main.object(forInfoDictionaryKey: "CLIENT_ID") as? String
    }
}

// Google 로그인 버튼을 위한 SwiftUI 뷰
struct GoogleSignInButton: View {
    @ObservedObject var signInManager = GoogleSignInManager.shared
    @State private var isLoading = false
    
    var body: some View {
        Button(action: {
            isLoading = true
            signInManager.signIn { success, error in
                isLoading = false
                if !success, let error = error {
                    print("Google 로그인 실패: \(error.localizedDescription)")
                }
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "g.circle")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.blue)
                }
                
                Text("Google로 로그인")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .disabled(signInManager.isLoggingIn || isLoading)
    }
}

// Google 로고 이미지가 없을 경우를 위한 대체 버튼
struct GoogleSignInButtonAlt: View {
    @ObservedObject var signInManager = GoogleSignInManager.shared
    @State private var isLoading = false
    
    var body: some View {
        Button(action: {
            isLoading = true
            signInManager.signIn { success, error in
                isLoading = false
                if !success, let error = error {
                    print("Google 로그인 실패: \(error.localizedDescription)")
                }
            }
        }) {
            HStack(spacing: 12) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image(systemName: "g.circle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(.red)
                }
                
                Text("Google로 로그인")
                    .font(.headline)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 44)
            .background(Color(.systemGray6))
            .cornerRadius(8)
        }
        .disabled(signInManager.isLoggingIn || isLoading)
    }
}

// GoogleSignInSwift 패키지의 GoogleSignInButton을 사용하는 래퍼 뷰
struct GoogleSignInSwiftUIButton: View {
    @ObservedObject var signInManager = GoogleSignInManager.shared
    
    var body: some View {
        GoogleSignInButton()
    }
}
