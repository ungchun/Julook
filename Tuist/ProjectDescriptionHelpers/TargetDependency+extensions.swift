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
  case feature = "Projects/Feature"
}

public enum TargetName: String {
  case core = "Core"
  case designSystem = "DesignSystem"
  case feature = "Feature"
  case home = "FeatureHome"
}

public enum ExternalDependency: String {
  case composableArchitecture = "ComposableArchitecture"
}
