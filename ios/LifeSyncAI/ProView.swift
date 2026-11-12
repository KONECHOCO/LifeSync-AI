import SwiftUI

/// Scheda Pro: stato dell'acquisto, sblocco, ripristino ed export extra.
struct ProView: View {
    @StateObject private var purchaseManager = PurchaseManager.shared
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Image(systemName: purchaseManager.isPro ? "crown.fill" : "crown")
                                .font(.system(size: 44))
                                .foregroundColor(.yellow)
                            Text("LifeSync AI Pro")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(purchaseManager.isPro ? "pro_status_active".localized : "pro_status_free".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(purchaseManager.isPro ? .green : .gray)
                            Text(purchaseManager.isPro ? "pro_active_desc".localized : "pro_free_desc".localized)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)

                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "nosign", color: .pink, title: "pw_f4_t".localized, subtitle: "pw_f4_s".localized)
                            FeatureRow(icon: "sparkles", color: .yellow, title: "pw_f1_t".localized, subtitle: "pw_f1_s".localized)
                            FeatureRow(icon: "square.and.arrow.up.on.square", color: .cyan, title: "pw_f2_t".localized, subtitle: "pw_f2_s".localized)
                            FeatureRow(icon: "lock.fill", color: .green, title: "pw_f3_t".localized, subtitle: "pw_f3_s".localized)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)

                        if !purchaseManager.isPro {
                            Button {
                                showingPaywall = true
                            } label: {
                                Text("pw_cta".localized)
                                    .font(.headline)
                                    .fontWeight(.bold)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 16)
                                    .background(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                                    .foregroundColor(.white)
                                    .cornerRadius(16)
                            }
                            Text("pw_price_note".localized)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 12) {
                            Button("pw_restore".localized) {
                                Task { await purchaseManager.restorePurchases() }
                            }
                            .font(.subheadline)
                            .foregroundColor(.cyan)

                            HStack(spacing: 16) {
                                if let privacyURL = URL(string: "https://github.com/KONECHOCO/LifeSync-AI/blob/main/PRIVACY.md") {
                                    Link("pw_privacy_link".localized, destination: privacyURL)
                                }
                                if let termsURL = URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/") {
                                    Link("pw_terms_link".localized, destination: termsURL)
                                }
                            }
                            .font(.footnote)
                            .foregroundColor(.gray)
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("tab_pro".localized)
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showingPaywall) {
                PaywallView()
            }
        }
    }
}
