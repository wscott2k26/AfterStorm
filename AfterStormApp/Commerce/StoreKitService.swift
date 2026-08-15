import Observation
import StoreKit

@MainActor
@Observable
final class StoreKitService {
    static let monthlyID = "com.stormandme.afterstorm.plus.monthly"
    static let yearlyID = "com.stormandme.afterstorm.plus.yearly"
    var hasPlus = false

    func refreshEntitlements() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if case .verified(let transaction) = result,
               [Self.monthlyID, Self.yearlyID].contains(transaction.productID) {
                entitled = true
            }
        }
        hasPlus = entitled
    }
}
