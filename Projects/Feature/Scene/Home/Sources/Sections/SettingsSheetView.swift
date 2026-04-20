import SwiftUI

import Core
import DesignSystem

struct SettingsSheetView: View {
  @Environment(\.dismiss) var dismiss
  @Environment(\.openURL) var openURL

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.w10)
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)

      SettingRowView(title: "문의하기", showArrow: true) {
        Amp.track(event: "settings_inquiry_clicked")
        if let url = URL(string: "mailto:leedool3003@gmail.com") {
          openURL(url)
        }
      }

      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)

      SettingRowView(title: "리뷰 남기기", showArrow: true) {
        Amp.track(event: "settings_review_clicked")
        let reviewURL = "https://apps.apple.com/app/id6743315707?action=write-review"
        if let url = URL(string: reviewURL) {
          UIApplication.shared.open(url)
        }
      }

      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)

      SettingRowView(title: "이용약관", showArrow: true) {
        Amp.track(event: "settings_terms_clicked")
        if let url = URL(
          string: "https://yawner.notion.site/1c792ec2705581ec8b98d5b25d5d94ab?source=copy_link"
        ) {
          openURL(url)
        }
      }

      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)

      SettingRowView(title: "개인정보처리방침", showArrow: true) {
        Amp.track(event: "settings_privacy_clicked")
        if let url = URL(
          string: "https://yawner.notion.site/1c792ec270558160a0f0c57392e4d1de?source=copy_link"
        ) {
          openURL(url)
        }
      }

      Divider()
        .background(Color.w25)
        .padding(.horizontal, 16)

      HStack {
        Text("버전 정보")
          .foregroundColor(.w)
          .font(.SF17R)

        Spacer()

        Text(appVersion)
          .foregroundColor(.w85)
          .font(.SF12B)
      }
      .padding(.horizontal, 16)
      .padding(.vertical, 16)

      Spacer()
    }
    .frame(maxWidth: .infinity, maxHeight: .infinity)
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
  }

  private var appVersion: String {
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0"
    return version
  }
}

private extension SettingsSheetView {
  struct SettingRowView: View {
    let title: String
    let showArrow: Bool
    let action: () -> Void

    var body: some View {
      Button(action: action) {
        HStack {
          Text(title)
            .foregroundColor(.w)
            .font(.SF17R)

          Spacer()

          if showArrow {
            Image(systemName: "chevron.right")
              .foregroundColor(.w)
              .font(.system(size: 20, weight: .bold))
          }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 16)
        .contentShape(Rectangle())
      }
      .buttonStyle(PlainButtonStyle())
    }
  }
}
