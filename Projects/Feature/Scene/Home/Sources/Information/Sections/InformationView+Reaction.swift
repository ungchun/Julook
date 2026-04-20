import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func ReactionButtonsView() -> some View {
    HStack(spacing: 12) {
      ReactionButton(
        state: store.state.dislikeButtonState,
        type: .dislike,
        text: "아쉬워요",
        action: { store.send(.dislikeButtonTapped) }
      )

      ReactionButton(
        state: store.state.likeButtonState,
        type: .like,
        text: "좋았어요",
        action: { store.send(.likeButtonTapped) }
      )
    }
    .padding(.bottom, 20)
  }

  @ViewBuilder
  func MyCommentSection() -> some View {
    VStack(alignment: .leading, spacing: 8) {
      myCommentHeader
      myCommentContent
    }
    .sheet(isPresented: .init(
      get: { store.state.isShowingCommentSheet },
      set: { store.send(.showCommentSheet($0)) }
    )) {
      CommentSheetView(store: store)
    }
    .confirmationDialog("", isPresented: .init(
      get: { store.state.isShowingEditActionSheet },
      set: { store.send(.showEditActionSheet($0)) }
    )) {
      editActionSheetButtons
    }
    .alert("코멘트 삭제", isPresented: .init(
      get: { store.state.isShowingDeleteAlert },
      set: { store.send(.showDeleteAlert($0)) }
    )) {
      deleteAlertButtons
    } message: {
      Text("코멘트를 삭제하시겠어요?")
    }
    .padding(.bottom, 40)
  }

  // MARK: - Subviews

  @ViewBuilder
  private var myCommentHeader: some View {
    HStack {
      Text("내 코멘트")
        .foregroundColor(.w85)
        .font(.SF12B)

      Spacer()

      if let userComment = store.state.userComment {
        Text(userComment.isPublic ? "전체공개" : "비공개")
          .foregroundColor(.w50)
          .font(.SF12R)
      }
    }
  }

  @ViewBuilder
  private var myCommentContent: some View {
    if let userComment = store.state.userComment {
      existingCommentView(userComment)
    } else {
      emptyCommentPrompt
    }
  }

  @ViewBuilder
  private func existingCommentView(_ userComment: UserComment) -> some View {
    VStack(alignment: .leading, spacing: 12) {
      Text(userComment.comment)
        .frame(maxWidth: .infinity, alignment: .leading)
        .foregroundColor(.w85)
        .font(.SF14R)
        .padding(16)
        .background(Color.w10)
        .cornerRadius(8)

      HStack {
        Text(formatDate(userComment.updatedAt))
          .foregroundColor(.w50)
          .font(.SF12R)

        Spacer()

        Text("수정")
          .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
          .font(.SF14R)
          .onTapGesture {
            store.send(.commentSectionTapped)
          }
      }
    }
  }

  @ViewBuilder
  private var emptyCommentPrompt: some View {
    Button(action: {
      store.send(.commentSectionTapped)
    }) {
      HStack {
        Text("터치해서 코멘트를 남겨보세요!")
          .foregroundColor(.w85)
          .font(.SF14R)
      }
      .frame(maxWidth: .infinity)
      .padding(16)
      .background(Color.w10)
      .cornerRadius(12)
    }
  }

  @ViewBuilder
  private var editActionSheetButtons: some View {
    Button("수정하기") { store.send(.showCommentSheet(true)) }
    Button("삭제하기", role: .destructive) { store.send(.showDeleteAlert(true)) }
    Button("취소하기", role: .cancel) { }
  }

  @ViewBuilder
  private var deleteAlertButtons: some View {
    Button("취소", role: .cancel) { store.send(.showDeleteAlert(false)) }
    Button("삭제하기", role: .destructive) { store.send(.confirmDelete) }
  }
}
