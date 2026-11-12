import Foundation

extension String {
    /// Helper di traduzione per la UI dell'app Watch: "key".localized
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}
