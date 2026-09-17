import Foundation
import StoreKit
import Combine

/// Gestore Abbonamenti In-App Purchase tramite StoreKit 2 per App Store
/// Gestisce l'abbonamento Auto-Rinnovabile €4,99/mese con 7 Giorni di Prova Gratuita.
final class SubscriptionManager: ObservableObject {
    static let shared = SubscriptionManager()
    
    // Product ID configurato su App Store Connect
    static let monthlySubscriptionID = "com.lifesync.ai.pro.monthly"
    
    @Published var subscriptionProduct: Product?
    @Published var isSubscribed: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    private var transactionListener: Task<Void, Error>?
    
    init() {
        // Avvia l'ascoltatore di transazioni in background
        transactionListener = listenForTransactions()
        
        Task {
            await fetchProducts()
            await updateSubscriptionStatus()
        }
    }
    
    deinit {
        transactionListener?.cancel()
    }
    
    /// Recupera le informazioni del prodotto da App Store
    @MainActor
    func fetchProducts() async {
        isLoading = true
        do {
            let products = try await Product.products(for: [SubscriptionManager.monthlySubscriptionID])
            self.subscriptionProduct = products.first
            self.isLoading = false
            print("✅ Prodotto caricato da App Store: \(products.first?.displayName ?? "") - \(products.first?.displayPrice ?? "")")
        } catch {
            self.isLoading = false
            self.errorMessage = "Impossibile caricare l'abbonamento: \(error.localizedDescription)"
            print("⚠️ Errore StoreKit: \(error.localizedDescription)")
        }
    }
    
    /// Acquista l'abbonamento con 7 giorni di prova gratis
    @MainActor
    func purchaseMonthlySubscription() async -> Bool {
        guard let product = subscriptionProduct else {
            errorMessage = "Prodotto non disponibile."
            return false
        }
        
        isLoading = true
        do {
            let result = try await product.purchase()
            isLoading = false
            
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updateSubscriptionStatus()
                await transaction.finish()
                print("🎉 Abbonamento attivato con successo (7 giorni gratis trascorsi prima del primo addebito di €4,99)!")
                return true
                
            case .userCancelled:
                print("ℹ️ Acquisto annullato dall'utente.")
                return false
                
            case .pending:
                print("⏳ Acquisto in attesa di approvazione (es. In-App Purchase della famiglia).")
                return false
                
            @unknown default:
                return false
            }
        } catch {
            isLoading = false
            errorMessage = "Errore durante l'acquisto: \(error.localizedDescription)"
            return false
        }
    }
    
    /// Ripristina gli acquisti dell'utente
    @MainActor
    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await updateSubscriptionStatus()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = "Impossibile ripristinare gli acquisti: \(error.localizedDescription)"
        }
    }
    
    /// Verifica lo stato dell'abbonamento attivo dell'utente
    @MainActor
    func updateSubscriptionStatus() async {
        var hasActiveSub = false
        
        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == SubscriptionManager.monthlySubscriptionID && transaction.revocationDate == nil {
                    hasActiveSub = true
                }
            } catch {
                print("⚠️ Errore verifica transazione: \(error)")
            }
        }
        
        self.isSubscribed = hasActiveSub
    }
    
    /// Ascolta nuove transazioni ed aggiornamenti di rinnovo
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updateSubscriptionStatus()
                    await transaction.finish()
                } catch {
                    print("⚠️ Transazione non verificata: \(error)")
                }
            }
        }
    }
    
    /// Helper per verificare la crittografia JWS della transazione Apple
    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified(_, let error):
            throw error
        case .verified(let safe):
            return safe
        }
    }
}
