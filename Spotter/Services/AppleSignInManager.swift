// AppleSignInManager.swift
// Apple ID 로그인 관리
// Created by woo on 3/30/25.

import SwiftUI
import AuthenticationServices
import CryptoKit

// Apple 로그인 관리 클래스
class AppleSignInManager: NSObject, ObservableObject {
    // 싱글톤 인스턴스
    static let shared = AppleSignInManager()
    
    // 현재 로그인 상태
    @Published var isLoggedIn: Bool = false
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    
    // 로그인 중 상태
    @Published var isLoggingIn: Bool = false
    
    // 리퀘스트 과정에서 사용되는 논스(nonce)
    private var currentNonce: String?
    
    private override init() {
        super.init()
        // 저장된 로그인 상태 불러오기
        loadLoginState()
    }
    
    // MARK: - 공개 메서드
    
    // 로그인 요청
    func signIn(completion: @escaping (Result<ASAuthorization, Error>) -> Void) {
        isLoggingIn = true
        
        let nonce = randomNonceString()
        currentNonce = nonce
        
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        
        // Fix for deprecated UIApplication.shared.windows property
        // Using UIWindowScene.windows on a relevant window scene instead
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let rootViewController = windowScene.windows.first?.rootViewController {
            authorizationController.presentationContextProvider = rootViewController as? ASAuthorizationControllerPresentationContextProviding
        }
        
        authorizationController.performRequests()
    }
    
    // 로그아웃
    func signOut() {
        isLoggedIn = false
        userName = ""
        userEmail = ""
        saveLoginState()
    }
    
    // MARK: - 내부 메서드
    
    // 로그인 상태 저장
    private func saveLoginState() {
        UserDefaults.standard.set(isLoggedIn, forKey: "apple_signin_logged_in")
        UserDefaults.standard.set(userName, forKey: "apple_signin_user_name")
        UserDefaults.standard.set(userEmail, forKey: "apple_signin_user_email")
    }
    
    // 로그인 상태 불러오기
    private func loadLoginState() {
        isLoggedIn = UserDefaults.standard.bool(forKey: "apple_signin_logged_in")
        userName = UserDefaults.standard.string(forKey: "apple_signin_user_name") ?? ""
        userEmail = UserDefaults.standard.string(forKey: "apple_signin_user_email") ?? ""
    }
    
    // 랜덤 논스 생성
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    // SHA256 해싱
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}

// MARK: - ASAuthorizationControllerDelegate
extension AppleSignInManager: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoggingIn = false
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            // 사용자 정보 추출
            if let fullName = appleIDCredential.fullName {
                userName = [fullName.givenName, fullName.familyName]
                    .compactMap { $0 }
                    .joined(separator: " ")
            }
            
            if let email = appleIDCredential.email {
                userEmail = email
            }
            
            // 로그인 상태 업데이트 및 저장
            isLoggedIn = true
            saveLoginState()
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoggingIn = false
        print("Apple Sign In Error: \(error.localizedDescription)")
    }
}

// 로그인 버튼을 위한 SwiftUI 뷰
struct AppleSignInButton: View {
    @ObservedObject var signInManager = AppleSignInManager.shared
    
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                request.requestedScopes = [.fullName, .email]
            },
            onCompletion: { result in
                switch result {
                case .success(let authResults):
                    // 로그인 성공 처리는 ASAuthorizationControllerDelegate에서 이루어짐
                    break
                case .failure(let error):
                    print("Apple Sign In Error: \(error.localizedDescription)")
                }
            }
        )
        .frame(height: 44)
        .cornerRadius(8)
        .disabled(signInManager.isLoggingIn)
    }
}
