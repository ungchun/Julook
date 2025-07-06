import Foundation
import ProjectDescription

extension TargetDependency {
  public static func external(externalDependency: ExternalDependency) -> TargetDependency {
    return .external(name: externalDependency.rawValue)
  }
  
  public static func target(name: TargetName) -> TargetDependency {
    return .target(name: name.rawValue)
  }
  
  public static func project(target: TargetName, projectPath: ProjectPath) -> TargetDependency {
    return .project(
      target: target.rawValue,
      path: .relativeToRoot(projectPath.rawValue)
    )
  }
}

public enum ProjectPath: String {
  case core = "Projects/Core"
  case designSystem = "Projects/DesignSystem"
  case scene = "Projects/Feature/Scene"
  case coordinator = "Projects/Feature/Coordinator"
}

public enum TargetName: String {
  case core = "Core"
  case designSystem = "DesignSystem"
  case tabs = "FeatureTabs"
  case home = "FeatureHome"
  case search = "FeatureSearch"
  case myMakgeolli = "FeatureMyMakgeolli"
  case splash = "FeatureSplash"
  case mainCoordinator = "MainCoordinator"
}

public enum ExternalDependency: String {
  case composableArchitecture = "ComposableArchitecture"
  case tcaCoordinators = "TCACoordinators"
  case supabase = "Supabase"
  case firebaseAnalytics = "FirebaseAnalytics"
  case firebaseCrashlytics = "FirebaseCrashlytics"
}
