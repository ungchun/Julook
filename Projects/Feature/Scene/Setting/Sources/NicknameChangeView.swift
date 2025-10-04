//
//  NicknameChangeView.swift
//  FeatureSetting
//
//  Created by Kim SungHun on 9/23/25.
//  Copyright © 2025 com.azhy.julook. All rights reserved.
//

import SwiftUI

import DesignSystem
import Core

import ComposableArchitecture

public struct NicknameChangeView: View {
  let store: StoreOf<NicknameChangeCore>
  
  public init(store: StoreOf<NicknameChangeCore>) {
    self.store = store
  }
  
  public var body: some View {
    ZStack {
      DesignSystemAsset.Colors.darkbase.swiftUIColor
        .ignoresSafeArea(.all)
      
      VStack(spacing: 0) {
        HStack {
          Spacer()
          
          Button(action: {
            store.send(.dismiss)
          }) {
            DesignSystemAsset.Images.close.swiftUIImage
              .resizable()
              .aspectRatio(contentMode: .fit)
              .frame(height: 26)
          }
        }
        .padding(.horizontal, 16)
        .padding(.top, 16)
        
        Spacer()
        
        VStack(spacing: 0) {
          HStack(spacing: 0) {
            Text("닉네임")
              .foregroundColor(DesignSystemAsset.Colors.primary.swiftUIColor)
              .font(.SF24B)
            Text(" 변경")
              .foregroundColor(.w)
              .font(.SF24B)
          }
          .padding(.bottom, 24)
          
          NicknameInputView(
            nickname: store.newNickname,
            isAvailable: store.isNicknameAvailable,
            shouldDismissKeyboard: store.isCheckingDuplicate,
            onNicknameChange: { nickname in
              store.send(.nicknameChanged(nickname))
            }
          )
          .frame(height: 56)
          .padding(.horizontal, 32)
          
          if let isAvailable = store.isNicknameAvailable {
            Text(isAvailable ? "사용할 수 있는 닉네임입니다" : "중복된 닉네임이에요")
              .foregroundColor(isAvailable ? .primary2 : .alrert)
              .font(.SF12B)
              .padding(.top, 12)
          }
        }
        
        Spacer()
        
        Button(action: {
          if !store.newNickname.isEmpty {
            if store.isNicknameAvailable == true {
              store.send(.saveButtonTapped)
            } else {
              store.send(.checkDuplicateButtonTapped)
            }
          }
        }) {
          HStack {
            Spacer()
            if store.isCheckingDuplicate {
              ProgressView()
                .progressViewStyle(CircularProgressViewStyle(tint: .w))
                .scaleEffect(0.8)
            } else {
              Text(store.isNicknameAvailable == true ? "완료" : "닉네임 중복 검사")
                .foregroundColor(getButtonTextColor())
                .font(.SF17R)
            }
            Spacer()
          }
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 16)
        .background(
          RoundedRectangle(cornerRadius: 12)
            .fill(getButtonBackgroundColor())
        )
        .disabled(store.newNickname.isEmpty || store.isCheckingDuplicate || store.isNicknameAvailable == false)
        .padding(.horizontal, 16)
        .padding(.bottom, 16)
      }
    }
    .onAppear {
      store.send(.onAppear)
    }
  }
}

private extension NicknameChangeView {
  func getButtonTextColor() -> Color {
    if store.newNickname.isEmpty || store.isNicknameAvailable == false {
      return .w25
    } else if store.isNicknameAvailable == true {
      return .w
    } else {
      return .w
    }
  }
  
  func getButtonBackgroundColor() -> Color {
    if store.newNickname.isEmpty || store.isNicknameAvailable == false {
      return DesignSystemAsset.Colors.w10.swiftUIColor
    } else if store.isNicknameAvailable == true {
      return DesignSystemAsset.Colors.goldenyellow.swiftUIColor
    } else {
      return DesignSystemAsset.Colors.lilac.swiftUIColor
    }
  }
}

private struct NicknameInputView: View {
  let nickname: String
  let isAvailable: Bool?
  let shouldDismissKeyboard: Bool
  let onNicknameChange: (String) -> Void
  
  @State private var focusedIndex: Int? = nil
  @State private var internalText: String = ""
  @FocusState private var isFocused: Bool
  
  private let maxLength = 6
  
  var body: some View {
    ZStack {
      if isAvailable == true {
        RoundedRectangle(cornerRadius: 12)
          .stroke(
            LinearGradient(
              gradient: Gradient(colors: [
                DesignSystemAsset.Colors.goldenyellow.swiftUIColor,
                DesignSystemAsset.Colors.lilac.swiftUIColor
              ]),
              startPoint: .top,
              endPoint: .bottom
            ),
            lineWidth: 2
          )
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
          )
          .frame(height: 56)
      } else {
        RoundedRectangle(cornerRadius: 12)
          .stroke(getBorderColor(), lineWidth: 2)
          .background(
            RoundedRectangle(cornerRadius: 12)
              .fill(DesignSystemAsset.Colors.darkgray.swiftUIColor)
          )
          .frame(height: 56)
      }
      
      HStack(spacing: 0) {
        ForEach(0..<maxLength, id: \.self) { index in
          CharacterCell(
            character: getCharacter(at: index),
            isFocused: focusedIndex == index,
            showDivider: index < maxLength - 1,
            borderColor: getBorderColor()
          )
        }
      }
      
      TextField("", text: $internalText)
        .focused($isFocused)
        .opacity(0)
        .allowsHitTesting(false)
        .onChange(of: internalText) { oldValue, newValue in
          let filtered = String(newValue.prefix(maxLength))
          if filtered != internalText {
            internalText = filtered
          }
          if filtered != nickname {
            onNicknameChange(filtered)
            updateFocus(for: filtered)
          }
        }
    }
    .onTapGesture {
      isFocused = true
      updateFocus(for: nickname)
    }
    .onAppear {
      internalText = nickname
      focusedIndex = nil
    }
    .onChange(of: nickname) { oldValue, newValue in
      if newValue != internalText {
        internalText = newValue
        updateFocus(for: newValue)
      }
    }
    .onChange(of: shouldDismissKeyboard) { oldValue, newValue in
      if newValue {
        isFocused = false
        focusedIndex = nil
      }
    }
  }
}

private extension NicknameInputView {
  func getCharacter(at index: Int) -> String {
    guard index < nickname.count else { return "" }
    let stringIndex = nickname.index(nickname.startIndex, offsetBy: index)
    return String(nickname[stringIndex])
  }
  
  func updateFocus(for text: String) {
    if text.count < maxLength {
      focusedIndex = text.count
    } else {
      focusedIndex = nil
    }
  }
  
  func getBorderColor() -> Color {
    if let isAvailable = isAvailable {
      return isAvailable
      ? DesignSystemAsset.Colors.goldenyellow.swiftUIColor
      : DesignSystemAsset.Colors.warmred.swiftUIColor
    } else {
      return DesignSystemAsset.Colors.lilac.swiftUIColor
    }
  }
}

private struct CharacterCell: View {
  let character: String
  let isFocused: Bool
  let showDivider: Bool
  let borderColor: Color
  
  var body: some View {
    HStack(spacing: 0) {
      ZStack {
        Rectangle()
          .fill(Color.clear)
          .frame(maxWidth: .infinity)
        
        Text(character)
          .foregroundColor(.w)
          .font(.SF20B)
        
        if isFocused && character.isEmpty {
          RoundedRectangle(cornerRadius: 1)
            .fill(DesignSystemAsset.Colors.w.swiftUIColor)
            .frame(width: 2, height: 24)
            .opacity(0.8)
        }
      }
      
      if showDivider {
        DashedDivider(borderColor: borderColor)
          .frame(width: 1, height: 56)
      }
    }
  }
}

private struct DashedDivider: View {
  let borderColor: Color
  
  var body: some View {
    VStack(spacing: 8) {
      ForEach(0..<5, id: \.self) { _ in
        Rectangle()
          .fill(borderColor)
          .frame(width: 1, height: 4)
      }
    }
    .frame(maxHeight: .infinity)
  }
}
