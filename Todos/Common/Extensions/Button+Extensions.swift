//
//  Button+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/2/21.
//

import SwiftUI
import SFSafeSymbols

extension Button {
    
    /// Create a Button using an SF Symbol
    init(_ systemImage: SFSymbol, action: @escaping () -> Void) {
        self.init(
            action: action,
            label: { Image(systemName: systemImage.rawValue) as! Label }
        )
    }
}

struct Button_Extensions_Previews: PreviewProvider {
    static var previews: some View {
        Button<Image>(.keyboard) {
            // Action
        }
    }
}

import SwiftUI

struct RoundedRectangleButtonStyle: ButtonStyle {
    var color: Color = Color(.windowBackgroundColor)
    
    func makeBody(configuration: Configuration) -> some View {
        RoundedRectangle(cornerRadius: 10)
            .frame(height: 50)
            .foregroundColor(color)
            .overlay(configuration.label.foregroundColor(color == Color(.windowBackgroundColor) ? .secondary : .white))
            .scaleEffect(configuration.isPressed ? 0.95 : 1)
    }
}

struct ButtonStyle_Extensions_Previews: PreviewProvider {
    static var previews: some View {
        
        VStack {
            Button("Tap Me") {}
                .buttonStyle(RoundedRectangleButtonStyle())

            Button("Tap Me") {}
                .buttonStyle(RoundedRectangleButtonStyle(color: .accentColor))
            
        }
        .padding()
    }
}
