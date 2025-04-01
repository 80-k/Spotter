// AppDelegate.swift
// 앱 델리게이트 구현
// Created by woo on 3/31/25.

import UIKit
import GoogleSignIn
import FirebaseCore

/// 앱 델리게이트 클래스
class AppDelegate: NSObject, UIApplicationDelegate {
    /// 앱 실행 시 호출
    func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        FirebaseApp.configure()
        return true
    }
    
    /// URL 처리 (Google 로그인 콜백)
    func application(_ app: UIApplication,
                     open url: URL,
                     options: [UIApplication.OpenURLOptionsKey: Any] = [:]) -> Bool {
        return GIDSignIn.sharedInstance.handle(url)
    }
    
    /// 앱 종료 시 호출
    func applicationWillTerminate(_ application: UIApplication) {
        print("AppDelegate: 앱이 종료됩니다. LiveActivity 정리 중...")
        LiveActivityService.shared.endActivity()
    }
} 