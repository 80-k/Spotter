//
//  HistoryListView.swift
//  운동 기록 목록 화면 - 테마 지원 개선
//  Created by woo on 3/29/25.
//

import SwiftUI
import SwiftData

struct HistoryListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.colorScheme) private var colorScheme
    
    @State private var viewModel: HistoryViewModel
    @State private var showingCalendarView = false
    @State private var selectedSession: WorkoutSession?
    @State private var activeWorkoutSession: WorkoutSession?
    @State private var sessionToDelete: WorkoutSession?
    @State private var showDeleteConfirmation = false
    
    init(modelContext: ModelContext) {
        self._viewModel = State(initialValue: HistoryViewModel(modelContext: modelContext))
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 16) {
                    // 통계 위젯
                    WorkoutStatisticsWidget(
                        totalWorkouts: viewModel.totalWorkouts,
                        streakDays: viewModel.streakDays,
                        totalDuration: viewModel.totalDuration,
                        averageWorkoutTime: viewModel.averageWorkoutTime
                    )
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 전체 세션 헤더
                    HStack {
                        Text("전체 세션")
                            .font(.headline)
                        
                        Spacer()
                        
                        Button(action: {
                            showingCalendarView = true
                        }) {
                            Label("달력 보기", systemImage: "calendar")
                                .font(.caption)
                                .foregroundColor(.blue)
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    
                    // 세션 목록
                    if viewModel.sessions.isEmpty {
                        ContentUnavailableView {
                            Label("운동 기록 없음", systemImage: "figure.run.circle")
                        } description: {
                            Text("아직 완료된 운동 기록이 없습니다.\n운동을 시작하고 완료해보세요!")
                        }
                        .padding(.top, 40)
                    } else {
                        LazyVStack(spacing: 12) {
                            ForEach(viewModel.sessions) { session in
                                Button(action: {
                                    // 완료된 운동을 터치하면 재활성화
                                    if let reactivatedSession = viewModel.reactivateSession(session) {
                                        activeWorkoutSession = reactivatedSession
                                    } else {
                                        // 재활성화 실패 시 상세 보기만 표시
                                        selectedSession = session
                                    }
                                }) {
                                    WorkoutSessionRow(session: session)
                                        .padding()
                                        .background(cardBackgroundColor)
                                        .cornerRadius(12)
                                        .shadow(color: shadowColor, radius: 4, x: 0, y: 2)
                                }
                                .buttonStyle(PlainButtonStyle())
                                .contextMenu {
                                    Button(role: .destructive) {
                                        // 삭제 확인 대화상자 표시
                                        sessionToDelete = session
                                        showDeleteConfirmation = true
                                    } label: {
                                        Label("삭제", systemImage: "trash")
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                }
                .padding(.bottom, 16)
            }
            .navigationTitle("운동 기록")
            .background(backgroundColor)
            .toolbar {
                // 테마 토글 버튼 추가
                ToolbarItem(placement: .topBarTrailing) {
                    CompactThemeToggleButton()
                }
            }
            .sheet(isPresented: $showingCalendarView) {
                CalendarView(viewModel: viewModel)
            }
            .sheet(item: $selectedSession) { session in
                WorkoutSessionDetailView(session: session)
            }
            .fullScreenCover(item: $activeWorkoutSession) { session in
                ActiveWorkoutView(
                    session: session,
                    modelContext: modelContext
                )
            }
            // 운동 완료 알림 수신 시 기록 새로고침
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WorkoutCompleted"))) { _ in
                print("운동 완료 알림 수신")
                viewModel.fetchSessions()
            }
            // 삭제 확인 대화상자
            .confirmationDialog("운동 기록을 삭제하시겠습니까?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
                Button("삭제", role: .destructive) {
                    if let session = sessionToDelete {
                        // 삭제 작업 수행
                        viewModel.deleteSession(session)
                        sessionToDelete = nil
                    }
                }
                Button("취소", role: .cancel) {
                    sessionToDelete = nil
                }
            } message: {
                Text("이 작업은 되돌릴 수 없습니다.")
            }
            .onAppear {
                print("기록 탭 나타남")
                viewModel.fetchSessions()
            }
            .refreshable {
                viewModel.fetchSessions()
            }
        }
    }
    
    // 배경색 - 다크 모드 대응
    private var backgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.systemBackground)
        default:
            return Color.gray.opacity(0.03)
        }
    }
    
    // 카드 배경색 - 다크 모드 대응
    private var cardBackgroundColor: Color {
        switch colorScheme {
        case .dark:
            return Color(UIColor.secondarySystemBackground)
        default:
            return Color.white
        }
    }
    
    // 그림자 색상 - 다크 모드 대응
    private var shadowColor: Color {
        switch colorScheme {
        case .dark:
            return Color.black.opacity(0.1)
        default:
            return Color.black.opacity(0.03)
        }
    }
}
