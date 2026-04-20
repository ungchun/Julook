import SwiftUI

import Core
import DesignSystem

extension InformationView {
  @ViewBuilder
  func AwardsView() -> some View {
    if let awards = store.state.makgeolli.awards, !awards.isEmpty {
      VStack(spacing: 0) {
        Group {
          if awards.count == 1 {
            SingleAwardView(award: awards[0])
          } else if awards.count == 2 {
            TwoAwardsView(awards: awards)
          } else {
            ThreeAwardsView(awards: awards)
          }
        }
        .padding(.bottom, 24)

        Rectangle()
          .fill(Color.w25)
          .frame(height: 1)
      }
      .padding(.bottom, 40)
    }
  }

  @ViewBuilder
  func SingleAwardView(award: String) -> some View {
    let awardComponents = parseAward(award)
    HStack {
      AwardContentView(
        year: awardComponents.year,
        competition: awardComponents.competition,
        prize: awardComponents.prize
      )
      Spacer()
    }
  }

  @ViewBuilder
  func TwoAwardsView(awards: [String]) -> some View {
    HStack(spacing: 12) {
      ForEach(0..<2) { index in
        let awardComponents = parseAward(awards[index])
        HStack(spacing: 0) {
          if index == 1 {
            Rectangle()
              .fill(Color.w25)
              .frame(width: 1, height: 58)
              .padding(.trailing, 16)
          }
          AwardContentView(
            year: awardComponents.year,
            competition: awardComponents.competition,
            prize: awardComponents.prize
          )
        }
        Spacer()
      }
    }
  }

  @ViewBuilder
  func ThreeAwardsView(awards: [String]) -> some View {
    HStack(spacing: 12) {
      ForEach(0..<3) { index in
        let awardComponents = parseAward(awards[index])
        HStack(spacing: 0) {
          if index == 1 || index == 2 {
            Rectangle()
              .fill(Color.w25)
              .frame(width: 1, height: 58)
              .padding(.trailing, 16)
          }
          AwardContentView(
            year: awardComponents.year,
            competition: awardComponents.competition,
            prize: awardComponents.prize
          )
        }
        Spacer()
      }
    }
  }

  @ViewBuilder
  func AwardContentView(year: String, competition: String, prize: String) -> some View {
    VStack(alignment: .leading, spacing: 0) {
      Text(year)
        .foregroundColor(.w50)
        .font(.SF12R)

      Text(competition)
        .foregroundColor(.w50)
        .font(.SF12R)

      Text(prize)
        .foregroundColor(.w)
        .font(.SF17R)
        .padding(.top, 4)
    }
  }

  private func parseAward(_ award: String) -> (
    year: String, competition: String, prize: String
  ) {
    let components = award.components(separatedBy: " ")
    if components.count >= 3 {
      let year = components[0]
      let prize = components.last ?? ""
      let competition = components.dropFirst().dropLast().joined(separator: " ")

      return (year, competition, prize)
    } else if components.count == 2 {
      return (components[0], "", components[1])
    } else {
      return ("", "", components[0])
    }
  }
}
