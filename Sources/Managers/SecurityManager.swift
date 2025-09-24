import Foundation
import LocalAuthentication

final class SecurityManager {
    private let pinKey = "user_pin"

    func savePIN(_ pin: String) {
        UserDefaults.standard.set(pin, forKey: pinKey)
    }

    func validatePIN(_ pin: String) -> Bool {
        UserDefaults.standard.string(forKey: pinKey) == pin
    }

    func canEvaluateBiometrics() -> Bool {
        let ctx = LAContext()
        var error: NSError?
        let ok = ctx.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error)
        return ok
    }

    func authenticate(reason: String = "Unlock") async -> Bool {
        let ctx = LAContext()
        do {
            try await ctx.evaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, localizedReason: reason)
            return true
        } catch {
            return false
        }
    }
}