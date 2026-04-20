import SwiftUI

import Core
import DesignSystem

struct HeaderView: View {
  @State private var isPresentingSettings = false

  var body: some View {
    HStack {
      Text("모아보기")
        .foregroundColor(.w)
        .font(.SFTitle)

      Spacer()

      Image(systemName: "gearshape.fill")
        .resizable()
        .aspectRatio(contentMode: .fit)
        .frame(width: 24, height: 24)
        .foregroundColor(.w50)
        .onTapGesture {
          Amp.track(event: "settings_icon_clicked")
          isPresentingSettings = true
        }
    }
    .padding(.horizontal, 16)
    .padding(.bottom, 10)
    .padding(.top, 20)
    .sheet(isPresented: $isPresentingSettings) {
      SettingsSheetView()
    }
  }
}
