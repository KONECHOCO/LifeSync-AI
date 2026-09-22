import SwiftUI

/// Scheda Abbonamento: stato Pro, avvio prova gratuita, ripristino e gestione.
struct ProView: View {
    @StateObject private var subscriptionManager = SubscriptionManager.shared
    @State private var showingPaywall = false

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 9/255, green: 13/255, blue: 22/255).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 20) {
                        VStack(spacing: 10) {
                            Image(systemName: subscriptionManager.isSubscribed ? "crown.fill" : "crown")
                                .font(.system(size: 44))
                                .foregroundColor(.yellow)
                            Text("LifeSync AI Pro")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            Text(subscriptionManager.isSubscribed ? "pro_status_active".localized : "pro_status_free".localized)
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(subscriptionManager.isSubscribed ? .green : .gray)
                            Text(subscriptionManager.isSubscribed ? "pro_active_desc".localized : "pro_free_desc".localized)
                                .font(.caption)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)

                        VStack(alignment: .leading, spacing: 16) {
                            FeatureRow(icon: "sparkles", color: .yellow, title: "pw_f1_t".localized, subtitle: "pw_f1_s".localized)
                            FeatureRow(icon: "lock.fill", color: .green, title: "pw_f3_t".localized, subtitle: "pw_f3_s".localized)
                            FeatureRow(icon: "nosign", color: .pink, title: "pw_f4_t".localized, subtitle: "pw_f4_s".localized)
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding()
                        .background(Color.white.opacity(0.05))
                        .cornerRadius(20)

                        if !subscriptionManager.isSubscribed {
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
                            Text("pw_sub_length".localized)
                                .font(.caption2)
                                .multilineTextAlignment(.center)
                                .foregroundColor(.gray)
                        }

                        VStack(spacing: 12) {
                            Button("pw_restore".localized) {
                                Task { await subscriptionManager.restorePurchases() }
                            }
                            .font(.subheadline)
                            .foregroundColor(.cyan)

                            if let manageURL = URL(string: "https://apps.apple.com/account/subscriptions") {
                                Link("pro_manage".localized, destination: manageURL)
                                    .font(.subheadline)
                                    .foregroundColor(.cyan)
                            }
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
