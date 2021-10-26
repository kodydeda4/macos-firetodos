//
//  Textfield+Extensions.swift
//  Todos
//
//  Created by Kody Deda on 6/3/21.
//

import SwiftUI

// Hides Textfield Halo Ring
extension NSTextField {
  open override var focusRingType: NSFocusRingType {
    get {.none }
    set {}
  }
}
