// ActiveWorkoutView.swift
// 활성 운동 세션 메인 화면 - 최신 SwiftUI 네비게이션 API 사용
// Created by woo on 3/31/25.

import SwiftUI
import SwiftData

struct ActiveWorkoutView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.scenePhase) private var scenePhase
    @Environment(\.appState) private var appState
    
    @State private var viewModel: ActiveWorkoutViewModel
    @State private var navigateToExerciseSelector = false
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
                ActiveWorkoutHeaderView(
                    elapsedTime: viewModel.elapsedTime,
                    onCancel: { showCancelAlert = true },
                    onComplete: { showCompletionAlert = true }
                )
                
                // 휴식 타이머 섹션
                if viewModel.restTimerActive, let activeExercise = viewModel.currentActiveExercise {
                    ActiveWorkoutRestTimerView(
                        viewModel: viewModel,
                        activeExercise: activeExercise
                    )
                }
                
                // 운동 내용 스크롤 뷰
                WorkoutContentView(viewModel: viewModel) {
                    navigateToExerciseSelector = true
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
            // 최신 네비게이션 API 사용
            .navigationDestination(isPresented: $navigateToExerciseSelector) {
                ExerciseSelectionView(
                    initialSelection: viewModel.exercises
                ) { selectedExercises in
                    updateExercisesInWorkout(selectedExercises)
                }
            }
            // 알림창들
            .applyAlerts(
                showCompletionAlert: $showCompletionAlert,
                showCancelAlert: $showCancelAlert,
                viewModel: viewModel,
                onWorkoutCompleted: { session in
                    completedSession = session
                    showingCompletionView = true
                },
                onWorkoutCancelled: {
                    dismiss()
                }
            )
            
            // 운동 완료 시트
            .fullScreenCover(isPresented: $showingCompletionView) {
                if let session = completedSession {
                    WorkoutCompletionView(session: session)
                }
            }
            
            // 라이프사이클 및 앱 상태 관리
            .onAppear {
                setupLiveActivity()
                setupAppStateCallbacks()
            }
            .onDisappear {
                clearAppStateCallbacks()
            }
            .onChange(of: scenePhase) { _, newPhase in
                appState.updateScenePhase(newPhase)
            }
        }
    }
    
    // 선택된 운동을 활성 운동에 업데이트하는 함수
    private func updateExercisesInWorkout(_ selectedExercises: [ExerciseItem]) {
        // 현재 활성 운동과 선택된 운동의 ID 세트 생성
        let currentIds = Set(viewModel.exercises.map { $0.id })
        let selectedIds = Set(selectedExercises.map { $0.id })
        
        // 새로 추가된 운동 처리
        for exercise in selectedExercises {
            if !currentIds.contains(exercise.id) {
                viewModel.addExerciseToWorkout(exercise)
            }
        }
        
        // 제거된 운동 처리
        for exercise in viewModel.exercises {
            if !selectedIds.contains(exercise.id) && !viewModel.completedExercises.contains(where: { $0.id == exercise.id }) {
                // 완료된 운동은 삭제하지 않음
                viewModel.deleteExerciseFromWorkout(exercise)
            }
        }
    }
    
    // LiveActivity 설정
    private func setupLiveActivity() {
        LiveActivityManager.shared.reset()
        
        LiveActivityManager.shared.startActivity(
            workoutName: viewModel.currentSession.template?.name ?? "운동",
            startTime: viewModel.currentSession.startTime
        )
        
        if viewModel.restTimerActive, let exercise = viewModel.currentActiveExercise {
            LiveActivityManager.shared.updateRestTimer(
                exerciseName: exercise.name,
                remainingTime: Int(viewModel.remainingRestTime)
            )
        } else {
            LiveActivityManager.shared.switchToWorkoutMode()
        }
    }
    
    // 앱 상태 콜백 설정
    private func setupAppStateCallbacks() {
        appState.onBackgrounded = { [weak viewModel] in
            viewModel?.handleAppBackgrounded()
        }
        
        appState.onForegrounded = { [weak viewModel] in
            viewModel?.handleAppForegrounded()
        }
    }
    
    // 앱 상태 콜백 제거
    private func clearAppStateCallbacks() {
        appState.onBackgrounded = nil
        appState.onForegrounded = nil
    }
}
