//
//  UserProfileView.swift
//  Spotter - 사용자 프로필 뷰
//
//  Created by woo on 3/30/25.
//

import SwiftUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var signInManager = AppleSignInManager.shared
    
    @State private var displayName: String = ""
    @State private var editingName: Bool = false
    
    // 사용자 프로필 이미지 (옵션)
    @State private var profileImage: UIImage?
    @State private var showingImagePicker = false
    
    // 백업 및 동기화 설정
    @State private var autoBackupEnabled = true
    @State private var syncFrequency = "매일"
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 섹션
                Section {
                    VStack(spacing: 20) {
                        // 프로필 이미지
                        if let image = profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 100, height: 100)
                                .clipShape(Circle())
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                        } else {
                            Image(systemName: "person.crop.circle.fill")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.blue)
                        }
                        
                        Button("프로필 사진 변경") {
                            showingImagePicker = true
                        }
                        .font(.caption)
                        .foregroundColor(.blue)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                // 이름 섹션
                Section(header: Text("계정 정보")) {
                    if editingName {
                        TextField("이름", text: $displayName)
                            .textContentType(.name)
                        
                        Button("저장") {
                            signInManager.userName = displayName
                            editingName = false
                        }
                    } else {
                        HStack {
                            Text("이름")
                            Spacer()
                            Text(signInManager.userName.isEmpty ? "사용자" : signInManager.userName)
                                .foregroundColor(.secondary)
                            Button(action: {
                                displayName = signInManager.userName
                                editingName = true
                            }) {
                                Image(systemName: "pencil")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    
                    HStack {
                        Text("이메일")
                        Spacer()
                        Text(signInManager.userEmail.isEmpty ? "정보 없음" : signInManager.userEmail)
                            .foregroundColor(.secondary)
                    }
                }
                
                // 동기화 설정
                Section(header: Text("백업 및 동기화")) {
                    Toggle("자동 백업", isOn: $autoBackupEnabled)
                    
                    if autoBackupEnabled {
                        Picker("동기화 주기", selection: $syncFrequency) {
                            Text("매일").tag("매일")
                            Text("매주").tag("매주")
                            Text("수동").tag("수동")
                        }
                    }
                    
                    Button(action: {
                        // 수동 백업 시작
                    }) {
                        Label("지금 백업", systemImage: "arrow.clockwise.icloud")
                    }
                    .disabled(!signInManager.isLoggedIn)
                }
                
                // 계정 관리
                Section(footer: Text("로그아웃하면 이 기기에서 동기화가 중단됩니다.")) {
                    Button(role: .destructive) {
                        signInManager.signOut()
                        dismiss()
                    } label: {
                        Label("로그아웃", systemImage: "arrow.right.square")
                    }
                }
            }
            .navigationTitle("내 프로필")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("완료") {
                        dismiss()
                    }
                }
            }
            // 이미지 피커 시트
            .sheet(isPresented: $showingImagePicker) {
                // ImagePicker() 컴포넌트는 별도로 구현 필요
                // 여기서는 예시만 포함
                Text("이미지 선택")
                    .padding()
            }
            .onAppear {
                displayName = signInManager.userName
            }
        }
    }
}

#Preview {
    UserProfileView()
}
