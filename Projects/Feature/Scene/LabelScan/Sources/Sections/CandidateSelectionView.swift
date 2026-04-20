import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct CandidateSelectionView: View {
  let store: StoreOf<LabelScanCore>

  var body: some View {
    VStack(spacing: 0) {
      Capsule()
        .fill(Color.w10)
        .frame(width: 36, height: 5)
        .padding(.top, 8)
        .padding(.bottom, 20)

      ScrollView {
        VStack(spacing: 16) {
          ForEach(store.candidates) { makgeolli in
            let imageURL = store.candidateImages[makgeolli.id]

            CandidateRow(
              makgeolli: makgeolli,
              imageURL: imageURL,
              store: store
            )

            if makgeolli.id != store.candidates.last?.id {
              Divider()
                .background(Color.w10)
            }
          }
        }
        .padding(.top, 16)
        .padding(.horizontal, 16)
      }
    }
    .background(DesignSystemAsset.Colors.darkbase.swiftUIColor)
  }
}
