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
                    
                    // 최근 기록 헤더
                    HStack {
                        Text("최근 운동 기록")
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
                                    selectedSession = session
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
                                        viewModel.deleteSession(session)
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
            // 운동 완료 알림 수신 시 기록 새로고침
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("WorkoutCompleted"))) { _ in
                print("운동 완료 알림 수신")
                viewModel.fetchSessions()
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
