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
        text: L10n.Common.Reaction.dislike,
        action: { store.send(.dislikeButtonTapped) }
      )

      ReactionButton(
        state: store.state.likeButtonState,
        type: .like,
        text: L10n.Common.Reaction.like,
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
    .alert(L10n.Information.Comment.DeleteAlert.title, isPresented: .init(
      get: { store.state.isShowingDeleteAlert },
      set: { store.send(.showDeleteAlert($0)) }
    )) {
      deleteAlertButtons
    } message: {
      Text(L10n.Information.Comment.DeleteAlert.message)
    }
    .padding(.bottom, 40)
  }

  // MARK: - Subviews

  @ViewBuilder
  private var myCommentHeader: some View {
    HStack {
      Text(L10n.Information.Comment.myComment)
        .foregroundColor(.w85)
        .font(.SF12B)

      Spacer()

      if let userComment = store.state.userComment {
        Text(userComment.isPublic ? L10n.Information.Comment.Visibility.public : L10n.Information.Comment.Visibility.private)
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

        Text(L10n.Information.Comment.edit)
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
        Text(L10n.Information.Comment.emptyPrompt)
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
    Button(L10n.Information.Comment.editAction) { store.send(.showCommentSheet(true)) }
    Button(L10n.Information.Comment.deleteAction, role: .destructive) { store.send(.showDeleteAlert(true)) }
    Button(L10n.Information.Comment.cancelAction, role: .cancel) { }
  }

  @ViewBuilder
  private var deleteAlertButtons: some View {
    Button(L10n.Common.Button.cancel, role: .cancel) { store.send(.showDeleteAlert(false)) }
    Button(L10n.Information.Comment.deleteAction, role: .destructive) { store.send(.confirmDelete) }
  }
}
