// ActiveWorkoutView.swift
// 활성 운동 세션 실행 화면
//  Created by woo on 3/29/25.

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var showingExerciseSelector = false
    @State private var showCompletionAlert = false
    @State private var showCancelAlert = false
    @State private var showingCompletionView = false
    @State private var completedSession: WorkoutSession?
    
    init(session: WorkoutSession, modelContext: ModelContext) {
        self._viewModel = State(initialValue: ActiveWorkoutViewModel(modelContext: modelContext, session: session))
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // 상단 헤더
                WorkoutHeaderView(
                    elapsedTime: viewModel.elapsedTime,
                    onCancel: { showCancelAlert = true },
                    onComplete: { showCompletionAlert = true }
                )
                
                // 휴식 타이머 섹션 - 활성화된 경우에만 표시
                if viewModel.restTimerActive, let activeExercise = viewModel.currentActiveExercise {
                    RestTimerSectionView(
                        exercise: activeExercise,
                        remainingTime: viewModel.remainingRestTime,
                        totalTime: viewModel.currentActiveSet?.restTime ?? 60
                    )
                    .transition(.move(edge: .top).combined(with: .opacity))
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                }
                
                // 모든 운동 리스트를 포함하는 스크롤 뷰
                ScrollView {
                    VStack(spacing: 16) {
                        // 현재 진행 중인 운동 섹션 - 활성화된 경우에만 표시
                        if let activeExercise = viewModel.currentActiveExercise {
                            VStack(alignment: .leading, spacing: 8) {
                                HStack {
                                    Image(systemName: "figure.strengthtraining.traditional")
                                        .foregroundColor(.blue)
                                    Text("현재 진행 중")
                                        .font(.headline)
                                        .foregroundColor(.blue)
                                    
                                    Spacer()
                                }
                                .padding(.horizontal)
                                .padding(.top, 8)
                                
                                WorkoutExerciseSection(
                                    viewModel: viewModel,
                                    exercise: activeExercise,
                                    isActive: true
                                )
                                .padding(.horizontal)
                            }
                            .padding(.bottom, 12)
                            .background(Color.blue.opacity(0.05))
                            .cornerRadius(12)
                            .padding(.horizontal)
                            .transition(.opacity.combined(with: .scale))
                        }
                        
                        // 대기 중인 운동 목록
                        let waitingExercises = viewModel.exercises.filter { exercise in
                            viewModel.currentActiveExercise?.id != exercise.id &&
                            !viewModel.completedExercises.contains { $0.id == exercise.id }
                        }
                        
                        if !waitingExercises.isEmpty {
                            SectionHeader(
                                title: "대기 중인 운동",
                                icon: "hourglass",
                                color: .orange
                            )
                            .padding(.horizontal)
                            
                            // 대기 중인 운동 목록
                            LazyVStack(spacing: 12) {
                                ForEach(waitingExercises) { exercise in
                                    WorkoutExerciseSection(
                                        viewModel: viewModel,
                                        exercise: exercise,
                                        isActive: false
                                    )
                                    .padding(.horizontal)
                                    // 섹션 전체를 비활성화하는 대신 세트 완료 버튼만 비활성화
                                    //.disabled(viewModel.isAnotherExerciseActive(exercise))
                                    .opacity(viewModel.isAnotherExerciseActive(exercise) ? 0.7 : 1.0)
                                }
                            }
                        }
                        
                        // 완료된 운동 목록
                        if !viewModel.completedExercises.isEmpty {
                            SectionHeader(
                                title: "완료된 운동",
                                icon: "checkmark.circle.fill",
                                color: .green
                            )
                            .padding(.horizontal)
                            .padding(.top, 8)
                            
                            LazyVStack(spacing: 12) {
                                ForEach(viewModel.completedExercises) { exercise in
                                    CompletedExerciseSectionView(
                                        viewModel: viewModel,
                                        exercise: exercise
                                    )
                                    .padding(.horizontal)
                                }
                            }
                        }
                        
                        // 운동 추가 버튼 (스크롤 뷰 맨 아래에 배치)
                        AddExerciseButton(action: {
                            showingExerciseSelector = true
                        })
                        .padding(.horizontal)
                        .padding(.vertical, 16)
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    if let templateName = viewModel.currentSession.template?.name {
                        Text(templateName)
                            .font(.headline)
                    }
                }
            }
            // 알림창 처리
            .alert("운동 완료", isPresented: $showCompletionAlert) {
                Button("취소", role: .cancel) { }
                Button("완료", role: .destructive) {
                    let success = viewModel.completeWorkout()
                    if success {
                        completedSession = viewModel.currentSession
                        showingCompletionView = true
                    } else {
                        dismiss()
                    }
                }
            } message: {
                Text("현재 운동을 완료하시겠습니까?")
            }
            .alert("운동 취소", isPresented: $showCancelAlert) {
                Button("아니오", role: .cancel) { }
                Button("예", role: .destructive) {
                    LiveActivityManager.shared.endActivity()
                    dismiss()
                }
            } message: {
                Text("정말로 운동을 취소하시겠습니까?\n저장되지 않은 운동 기록은 사라집니다.")
            }
            .alert("운동 삭제", isPresented: Binding(
                get: { viewModel.exerciseToDelete != nil },
                set: { if !$0 { viewModel.exerciseToDelete = nil } }
            )) {
                Button("취소", role: .cancel) {
                    viewModel.exerciseToDelete = nil
                }
                Button("삭제", role: .destructive) {
                    if let exercise = viewModel.exerciseToDelete {
                        viewModel.deleteExerciseFromWorkout(exercise)
                    }
                    viewModel.exerciseToDelete = nil
                }
            } message: {
                if let exercise = viewModel.exerciseToDelete {
                    Text("\(exercise.name) 운동을 정말로 삭제하시겠습니까?\n모든 세트 정보가 함께 삭제됩니다.")
                } else {
                    Text("")
                }
            }
            // 운동 선택 시트
            .sheet(isPresented: $showingExerciseSelector) {
                WorkoutExerciseSelectorView(
                    onExerciseSelected: { exercise in
                        viewModel.addExerciseToWorkout(exercise)
                    },
                    isExerciseSelected: { exercise in
                        viewModel.exercises.contains(where: { $0.id == exercise.id })
                    }
                )
            }
            // 운동 완료 시트
            .fullScreenCover(isPresented: $showingCompletionView) {
                if let session = completedSession {
                    WorkoutCompletionView(session: session)
                }
            }
            .onAppear {
                // 다이나믹 아일랜드 활성화
                LiveActivityManager.shared.startActivity(
                    workoutName: viewModel.currentSession.template?.name ?? "운동",
                    startTime: viewModel.currentSession.startTime
                )
                
                // 주기적으로 경과 시간 업데이트
                Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { _ in
                    LiveActivityManager.shared.updateElapsedTime()
                }
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .background {
                    updateLiveActivityWithRestingSet()
                }
            }
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.currentActiveExercise != nil)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.restTimerActive)
            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: viewModel.completedExercises.count)
        }
    }
    
    // 현재 휴식 중인 세트가 있으면 다이나믹 아일랜드 업데이트
    private func updateLiveActivityWithRestingSet() {
        if viewModel.restTimerActive, let exercise = viewModel.currentActiveExercise {
            LiveActivityManager.shared.updateRestTimer(
                exerciseName: exercise.name,
                remainingTime: Int(viewModel.remainingRestTime)
            )
        }
    }
}

// 섹션 헤더 컴포넌트
struct SectionHeader: View {
    let title: String
    let icon: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
            
            Text(title)
                .font(.headline)
                .foregroundColor(color)
            
            Spacer()
        }
        .padding(.top, 8)
    }
}
