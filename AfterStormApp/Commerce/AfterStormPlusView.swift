import StoreKit
import SwiftUI

struct AfterStormPlusView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var store = StoreKitService()
    private let productIDs = [StoreKitService.monthlyID, StoreKitService.yearlyID]

    var body: some View {
        NavigationStack {
            ZStack {
                AfterStormTheme.worldGradient.ignoresSafeArea()
                SubscriptionStoreView(productIDs: productIDs) {
                    VStack(spacing: 10) {
                        Image(systemName: "cloud.sun.fill").font(.system(size: 54)).foregroundStyle(AfterStormTheme.spark)
                        Text("AfterStorm+").font(.largeTitle.bold())
                        if store.hasPlus {
                            Label("Your AfterStorm+ access is active", systemImage: "checkmark.seal.fill")
                                .font(.subheadline.bold())
                                .foregroundStyle(AfterStormTheme.restoredGreen)
                        }
                        Text("More worlds, deeper customization, seasonal restoration themes, and expanded intelligent quest planning.")
                            .multilineTextAlignment(.center).foregroundStyle(.secondary)
                        Text("The core restoration loop stays free.").font(.footnote.bold()).foregroundStyle(AfterStormTheme.restoredGreen)
                    }.padding(.horizontal, 20)
                }
            }
            .navigationTitle("AfterStorm+")
            .task { await store.refreshEntitlements() }
            .toolbar { ToolbarItem(placement: .topBarTrailing) { Button("Done") { dismiss() } } }
        }
    }
}
