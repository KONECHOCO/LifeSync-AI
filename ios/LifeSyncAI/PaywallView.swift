import SwiftUI
import StoreKit

/// Schermata Paywall per la monetizzazione dell'app LifeSync AI Pro
/// Offre 7 Giorni di Prova Gratuita, poi €4,99/mese auto-rinnovabile.
struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var subManager = SubscriptionManager.shared
    @State private var isPurchasing = false
    
    var body: some View {
        ZStack {
            Color(red: 9/255, green: 13/255, blue: 22/255)
                .ignoresSafeArea()
            
            VStack(spacing: 24) {
                
                // Pulsante Chiudi
                HStack {
                    Spacer()
                    Button(action: { dismiss() }) {
                        Image(systemName: "xmark.circle.fill")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                
                // Hero App Icon & Title
                VStack(spacing: 12) {
                    ZStack {
                        Circle()
                            .fill(LinearGradient(colors: [.cyan, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                            .frame(width: 80, height: 80)
                            .shadow(color: .cyan.opacity(0.5), radius: 20)
                        
                        Image(systemName: "brain.head.profile")
                            .font(.system(size: 40))
                            .foregroundColor(.white)
                    }
                    
                    Text("LifeSync AI Pro")
                        .font(.largeTitle)
                        .fontWeight(.black)
                        .foregroundColor(.white)
                    
                    Text("Sblocca il tuo assistente diario completo")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                
                // 7 Days Trial Highlight Badge
                HStack(spacing: 8) {
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                    Text("7 GIORNI DI PROVA GRATUITA")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(.yellow)
                    Image(systemName: "star.fill")
                        .foregroundColor(.yellow)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.yellow.opacity(0.15))
                .overlay(RoundedRectangle(cornerRadius: 20).stroke(Color.yellow.opacity(0.4), lineWidth: 1))
                .cornerRadius(20)
                
                // Features Included List
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "sparkles", color: .yellow, title: "Riepilogo Serale AI Illimitato", subtitle: "Generazione automatica ogni giorno alle 23:00")
                    FeatureRow(icon: "location.fill", color: .cyan, title: "Tracciamento Luoghi & Passi", subtitle: "CoreLocation Visit ultra-efficiente (<0.8% batt)")
                    FeatureRow(icon: "bubble.left.and.bubble.right.fill", color: .purple, title: "Uso app comunicazione", subtitle: "Compatibile con Screen Time quando l'autorizzazione Apple e disponibile")
                    FeatureRow(icon: "mic.fill", color: .pink, title: "Diario Vocale Rapido", subtitle: "Trascrizione automatica ed elaborazione note vocali")
                    FeatureRow(icon: "lock.fill", color: .green, title: "Archivio personale", subtitle: "Salvataggio locale dei dati usati per il riepilogo giornaliero")
                }
                .padding()
                .background(Color.white.opacity(0.04))
                .cornerRadius(20)
                
                Spacer()
                
                // CTA Subscription Button
                VStack(spacing: 12) {
                    Button(action: startTrial) {
                        HStack {
                            if isPurchasing || subManager.isLoading {
                                ProgressView()
                                    .tint(.black)
                            } else {
                                Text("Inizia 7 Giorni Gratis")
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(LinearGradient(colors: [.cyan, .purple], startPoint: .leading, endPoint: .trailing))
                        .foregroundColor(.white)
                        .cornerRadius(16)
                        .shadow(color: .cyan.opacity(0.4), radius: 15)
                    }
                    .disabled(isPurchasing || subManager.isLoading)
                    
                    Text("Poi 4,99 €/mese. Annulla in qualsiasi momento dalle impostazioni dell'Apple ID.")
                        .font(.caption2)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.gray)
                    
                    // Restore purchases
                    Button("Ripristina Acquisti") {
                        Task { await subManager.restorePurchases() }
                    }
                    .font(.caption)
                    .foregroundColor(.cyan)
                    .padding(.top, 4)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func startTrial() {
        isPurchasing = true
        Task {
            let success = await subManager.purchaseMonthlySubscription()
            isPurchasing = false
            if success {
                dismiss()
            }
        }
    }
}

struct FeatureRow: View {
    let icon: String
    let color: Color
    let title: String
    let subtitle: String
    
    var body: some View {
        HStack(spacing: 14) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)
                .frame(width: 32)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.subheadline)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                Text(subtitle)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
    }
}
