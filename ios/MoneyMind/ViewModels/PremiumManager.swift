import SwiftUI

@Observable
@MainActor
class PremiumManager {
    var isPremium: Bool = false
    var showPaywall: Bool = false

    func unlock() {
        isPremium = true
        showPaywall = false
    }

    func restore() {
        isPremium = true
        showPaywall = false
    }
}
