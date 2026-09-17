import Foundation
import SwiftUI

/// Gestore della localizzazione multi-lingua nativa per iOS (Italiano, English, Español, Français)
final class LocalizationManager: ObservableObject {
    static let shared = LocalizationManager()
    
    @Published var currentLanguage: String = Locale.current.language.languageCode?.identifier ?? "it"
    
    /// Restituisce la stringa tradotta dal file Localizable.xcstrings del bundle
    func localized(_ key: String) -> String {
        return NSLocalizedString(key, comment: "")
    }
}

extension String {
    /// Helper per la traduzione immediata in SwiftUI: "key".localized
    var localized: String {
        return NSLocalizedString(self, comment: "")
    }
}
