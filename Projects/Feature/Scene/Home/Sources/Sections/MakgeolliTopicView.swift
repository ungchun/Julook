import SwiftUI

import Core
import DesignSystem

import ComposableArchitecture

struct MakgeolliTopicView: View {
  let store: StoreOf<HomeCore>

  var body: some View {
    VStack(spacing: 20) {
      HStack(alignment: .center, spacing: 8) {
        Text(L10n.Home.Section.filterByTopic)
          .foregroundColor(.w)
          .font(.SF20B)
        Spacer()
      }
      .padding(.horizontal, 16)

      ScrollView(.horizontal, showsIndicators: false) {
        LazyHStack(spacing: 16) {
          if store.isLoadingAwards {
            ForEach(0..<3, id: \.self) { idx in
              RoundedRectangle(cornerRadius: 16)
                .fill(Color.darkgray)
                .frame(width: 160, height: 100)
                .overlay {
                  ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .w))
                }
                .padding(.leading, idx == 0 ? 16 : 0)
            }
          } else {
            ForEach(Array(store.awards.enumerated()), id: \.element.id) { idx, award in
              if award.type == "korea_award" {
                RoundedRectangle(cornerRadius: 16)
                  .fill(LinearGradient.warmNeutral)
                  .frame(width: 160, height: 100)
                  .overlay {
                    HStack {
                      VStack {
                        Spacer()
                        let displayName = award.localizedName(for: .current)
                        let components = displayName.components(separatedBy: " ")
                        VStack(alignment: .leading, spacing: 0) {
                          ForEach(components, id: \.self) { component in
                            Text(component)
                              .foregroundColor(.w)
                              .font(.SF12B)
                          }
                        }
                        .padding(.bottom, 16)
                      }
                      Spacer()
                      VStack {
                        DesignSystemAsset.Images.koreaAwardsLogo.swiftUIImage
                          .resizable()
                          .aspectRatio(contentMode: .fit)
                          .frame(height: 48)
                          .padding(.top, 16)
                        Spacer()
                      }
                    }
                    .padding(.horizontal, 16)
                  }
                  .padding(.leading, idx == 0 ? 16 : 0)
                  .onTapGesture {
                    Amp.track(event: "topic_clicked", properties: [
                      "topic_name": award.name
                    ])
                    store.send(.topicItemTapped(award))
                  }
              }
            }
          }
        }
      }
    }
    .padding(.bottom, 20)
  }
}
