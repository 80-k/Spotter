//
//  UserProfileView.swift
//  Spotter - 사용자 프로필 뷰 (통합 인증 지원)
//
//  Created by woo on 3/30/25.
//

import SwiftUI
import PhotosUI

struct UserProfileView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var authManager = AuthManager.shared
    
    @State private var displayName: String = ""
    @State private var editingName: Bool = false
    
    // 사용자 프로필 이미지 (옵션)
    @State private var profileImage: UIImage?
    @State private var selectedItem: PhotosPickerItem?
    @State private var showingImagePicker = false
    
    // 백업 및 동기화 설정
    @State private var autoBackupEnabled = true
    @State private var syncFrequency = "매일"
    
    // 계정 삭제 확인
    @State private var showingLogoutAlert = false
    
    var body: some View {
        NavigationStack {
            Form {
                // 프로필 섹션
                Section {
                    VStack(spacing: 20) {
                        // 프로필 이미지
                        ZStack {
                            // 기본 프로필 이미지 또는 로드된 이미지
                            if let image = profileImage {
                                Image(uiImage: image)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 100, height: 100)
                                    .clipShape(Circle())
                                    .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            } else {
                                // 원격 이미지 URL이 있으면 AsyncImage로 로드
                                ProfileImageView(
                                    imageURL: authManager.profileImageURL,
                                    placeholderImage: "person.crop.circle.fill",
                                    size: 100
                                )
                                .overlay(Circle().stroke(Color.blue, lineWidth: 2))
                            }
                            
                            // 편집 버튼
                            if isCustomProfileAllowed {
                                VStack {
                                    Spacer()
                                    HStack {
                                        Spacer()
                                        PhotosPicker(
                                            selection: $selectedItem,
                                            matching: .images,
                                            photoLibrary: .shared()
                                        ) {
                                            Image(systemName: "pencil.circle.fill")
                                                .symbolRenderingMode(.multicolor)
                                                .font(.system(size: 30))
                                                .background(Color.white.clipShape(Circle()))
                                        }
                                        .buttonStyle(.borderless)
                                    }
                                }
                                .frame(width: 100, height: 100)
                            }
                        }
                        
                        if isCustomProfileAllowed {
                            Text("프로필 사진 변경")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 10)
                }
                
                // 이름 섹션
                Section(header: Text("계정 정보")) {
                    // 로그인 제공자 정보
                    HStack {
                        Label(
                            "로그인 방식",
                            systemImage: authManager.authProvider == .apple ? "apple.logo" : "g.circle"
                        )
                        .foregroundColor(authManager.authProvider == .apple ? .primary : .red)
                        
                        Spacer()
                        
                        Text(authManager.authProvider.rawValue)
                            .foregroundColor(.secondary)
                    }
                    
                    // 이름 필드
                    if editingName {
                        TextField("이름", text: $displayName)
                            .textContentType(.name)
                        
                        Button("저장") {
                            // 이름 변경 저장 구현 필요
                            // 현재는 로컬 저장만 구현
                            editingName = false
                        }
                    } else {
                        HStack {
                            Text("이름")
                            Spacer()
                            Text(authManager.userName.isEmpty ? "사용자" : authManager.userName)
                                .foregroundColor(.secondary)
                            
                            // Google 로그인 사용자만 이름 편집 가능 (Apple 로그인은 불가)
                            if isCustomProfileAllowed {
                                Button(action: {
                                    displayName = authManager.userName
                                    editingName = true
                                }) {
                                    Image(systemName: "pencil")
                                        .foregroundColor(.blue)
                                }
                            }
                        }
                    }
                    
                    // 이메일 정보
                    HStack {
                        Text("이메일")
                        Spacer()
                        Text(authManager.userEmail.isEmpty ? "정보 없음" : authManager.userEmail)
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
                        performBackup()
                    }) {
                        Label("지금 백업", systemImage: "arrow.clockwise.icloud")
                    }
                }
                
                // 계정 관리
                Section(footer: Text("로그아웃하면 이 기기에서 동기화가 중단됩니다.")) {
                    Button(role: .destructive) {
                        showingLogoutAlert = true
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
            .onChange(of: selectedItem) { _, item in
                loadTransferable(from: item)
            }
            .alert("로그아웃", isPresented: $showingLogoutAlert) {
                Button("취소", role: .cancel) { }
                Button("로그아웃", role: .destructive) {
                    authManager.signOut()
                    dismiss()
                }
            } message: {
                Text("정말 로그아웃하시겠습니까?\n로그아웃하면 이 기기에서 동기화가 중단됩니다.")
            }
            .onAppear {
                displayName = authManager.userName
            }
        }
    }
    
    // 사용자 지정 프로필 허용 여부 (Google만 허용)
    private var isCustomProfileAllowed: Bool {
        return authManager.authProvider == .google
    }
    
    // 백업 실행
    private func performBackup() {
        // 백업 로직 구현
        // 클라우드 저장소에 데이터 업로드 등
    }
    
    // 이미지 로드 처리
    private func loadTransferable(from imageSelection: PhotosPickerItem?) {
        guard let imageSelection else { return }
        
        imageSelection.loadTransferable(type: Data.self) { result in
            DispatchQueue.main.async {
                guard imageSelection == self.selectedItem else { return }
                
                switch result {
                case .success(let data):
                    if let data = data, let uiImage = UIImage(data: data) {
                        self.profileImage = uiImage
                        // 실제 구현에서는 이미지를 서버에 업로드하고 URL 업데이트 필요
                    }
                case .failure(let error):
                    print("이미지 로드 실패: \(error)")
                }
            }
        }
    }
}

#Preview {
    UserProfileView()
}
