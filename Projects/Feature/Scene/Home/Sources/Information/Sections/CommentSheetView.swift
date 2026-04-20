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
        Button("취소") {
          store.send(.showCommentSheet(false))
        }
        .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
        .font(.SF17R)

        Spacer()

        Text(store.state.userComment != nil ? "코멘트 수정" : "코멘트 남기기")
          .foregroundColor(.w)
          .font(.SF17B)

        Spacer()

        Button("저장") {
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

      TextField("막걸리에 대한 생각을 자유롭게 적어주세요.", text: $commentText, axis: .vertical)
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

        Text("비공개")
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
