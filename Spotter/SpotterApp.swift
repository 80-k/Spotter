//
//  SpotterApp.swift
//  Spotter
//
//  Created by woo on 3/29/25.
//
import SwiftUI
import SwiftData

@main
struct SpotterApp: App {
    // 데이터 모델 컨테이너 정의
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            ExerciseItem.self,
            WorkoutTemplate.self,
            WorkoutSession.self,
            WorkoutSet.self,
        ])
        
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("모델 컨테이너 생성 실패: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            MainTabView()
        }
        .modelContainer(sharedModelContainer)
    }
}

// 메인 탭 뷰
struct MainTabView: View {
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        TabView {
            // 기록 탭
            HistoryListView(modelContext: modelContext)
                .tabItem {
                    Label("기록", systemImage: "list.bullet.clipboard")
                }
            
            // 시작 탭
            WorkoutTemplateListView(modelContext: modelContext)
                .tabItem {
                    Label("시작", systemImage: "play.circle")
                }
//            
//            // 운동 탭
//            ExerciseListView(modelContext: modelContext)
//                .tabItem {
//                    Label("운동", systemImage: "dumbbell")
//                }
        }
    }
}
