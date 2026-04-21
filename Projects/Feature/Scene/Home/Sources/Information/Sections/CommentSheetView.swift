import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct CommentSheetView: View {
  let store: StoreOf<InformationCore>

  @State private var commentText: String = ""
  @State private var isPublic: Bool = true

  @FocusState private var isTextEditorFocused: Bool

  var body: some View {
    VStack(alignment: .leading, spacing: 0) {
      HStack {
        Button(L10n.Common.Button.cancel) {
          store.send(.showCommentSheet(false))
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .font(.SF17R)

        Spacer()

        Text(store.state.userComment != nil ? L10n.Information.CommentSheet.Title.edit : L10n.Information.CommentSheet.Title.create)
          .foregroundColor(.w)
          .font(.SF17B)

        Spacer()

        Button(L10n.Common.Button.save) {
          store.send(.saveComment(commentText, isPublic))
        }
        .foregroundColor(
          commentText.isEmpty
          ? .w50 : DesignSystemAsset.Colors.primary.swiftUIColor
        )
        .font(.SF17R)
        .disabled(commentText.isEmpty)
      }
      .padding(16)

      Divider()
        .padding(.bottom, 16)

      TextField(L10n.Information.CommentSheet.placeholder, text: $commentText, axis: .vertical)
        .foregroundColor(.w85)
        .font(.SF14R)
        .focused($isTextEditorFocused)
        .lineLimit(10...15)
        .onChange(of: commentText) { _, newValue in
          if newValue.count > 200 {
            commentText = String(newValue.prefix(200))
          }
        }
        .padding(.horizontal, 16)

      Divider()
        .padding(.vertical, 16)

      HStack(spacing: 8) {
        Spacer()

        Text(L10n.Information.Comment.Visibility.private)
          .foregroundColor(.w50)
          .font(.SF14R)

        Button(action: {
          isPublic.toggle()
        }) {
          Image(systemName: !isPublic ? "checkmark.circle.fill" : "circle")
            .foregroundColor(!isPublic ? DesignSystemAsset.Colors.primary.swiftUIColor : .w50)
        }
      }
      .padding(.horizontal, 16)

      Spacer()
    }
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
    .onAppear {
      if let userComment = store.state.userComment {
        commentText = userComment.comment
        isPublic = userComment.isPublic
      }
    }
  }
}
