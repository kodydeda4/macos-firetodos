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
