import XCTest
import SwiftUI

@testable import DesignSystem

final class DesignSystemAssetTests: XCTestCase {

  // MARK: - Color assets accessible

  func test_colorAssets_loadable() {
    XCTAssertNotNil(DesignSystemAsset.Colors.darkbase.color)
    XCTAssertNotNil(DesignSystemAsset.Colors.darkgray.color)
    XCTAssertNotNil(DesignSystemAsset.Colors.primary.color)
  }

  func test_colorAssets_swiftUIAccessible() {
    _ = DesignSystemAsset.Colors.darkbase.swiftUIColor
    _ = DesignSystemAsset.Colors.primary.swiftUIColor
  }

  // MARK: - Image assets accessible

  func test_imageAssets_loadable() {
    XCTAssertNotNil(DesignSystemAsset.Images.defaultMakgeolli.image)
    XCTAssertNotNil(DesignSystemAsset.Images.arrowRight.image)
  }

  func test_imageAssets_swiftUIAccessible() {
    _ = DesignSystemAsset.Images.defaultMakgeolli.swiftUIImage
    _ = DesignSystemAsset.Images.arrowRight.swiftUIImage
  }

  // MARK: - Score images 0-5

  func test_scoreImages_allPresent() {
    XCTAssertNotNil(DesignSystemAsset.Images._0Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images._1Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images._2Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images._3Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images._4Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images._5Score.image)
    XCTAssertNotNil(DesignSystemAsset.Images.nillScore.image)
  }
}
