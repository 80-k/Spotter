import Foundation
import SwiftUI

/// 템플릿 화면에 필요한 뷰모델과 컴포넌트를 한번에 제공하는 구조체
struct TemplateViewComponents {
    let viewModel: ActorTemplateViewModel
    let actions: TemplateActionsHandler
}

// MARK: - DependencyContainer 확장

extension DependencyContainer {
    /// 템플릿 뷰 관련 컴포넌트를 생성하여 반환
    func makeTemplateViewComponents() -> TemplateViewComponents {
        let vm = makeActorTemplateViewModel() ?? ActorTemplateViewModel(repository: makeTemplateRepository())
        let actions = TemplateActionsHandler(viewModel: vm)
        return TemplateViewComponents(viewModel: vm, actions: actions)
    }
    
    /// 템플릿 레포지토리 생성
    func makeTemplateRepository() -> TemplateRepository {
        return TemplateRepository(modelContext: mainContext)
    }
    
    /// 액터 기반 템플릿 뷰모델 생성 또는 캐시된 인스턴스 반환
    func makeActorTemplateViewModel() -> ActorTemplateViewModel? {
        if let existingVM = cachedViewModels[ActorTemplateViewModel.identifier] as? ActorTemplateViewModel {
            return existingVM
        }
        
        let repo = makeTemplateRepository()
        let vm = ActorTemplateViewModel(repository: repo)
        cachedViewModels[ActorTemplateViewModel.identifier] = vm
        return vm
    }
} 