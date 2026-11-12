import Foundation
import StoreKit
import Combine

/// Gestore dell'acquisto Pro tramite StoreKit 2.
/// LifeSync AI Pro è un acquisto unico (non consumabile) di 3,99 €: rimuove la pubblicità
/// e sblocca alcune funzioni aggiuntive. Nessun abbonamento, nessun addebito ricorrente.
final class PurchaseManager: ObservableObject {
    static let shared = PurchaseManager()

    // Product ID configurato su App Store Connect (non consumabile)
    static let proProductID = "com.lifesync.ai.pro.onetime"

    @Published var proProduct: Product?
    @Published var isPro: Bool = false
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    private var transactionListener: Task<Void, Error>?

    init() {
        // Avvia l'ascoltatore di transazioni in background
        transactionListener = listenForTransactions()

        Task {
            await fetchProducts()
            await updatePurchaseStatus()
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
            let products = try await Product.products(for: [PurchaseManager.proProductID])
            self.proProduct = products.first
            self.isLoading = false
            if products.isEmpty {
                print("⚠️ Nessun prodotto trovato per \(PurchaseManager.proProductID)")
            }
            print("✅ Prodotto caricato da App Store: \(products.first?.displayName ?? "") - \(products.first?.displayPrice ?? "")")
        } catch {
            self.isLoading = false
            print("⚠️ Errore StoreKit: \(error.localizedDescription)")
        }
    }

    /// Acquista LifeSync AI Pro con un pagamento unico (nessun abbonamento).
    @MainActor
    func purchasePro() async -> Bool {
        if proProduct == nil {
            await fetchProducts()
        }
        guard let product = proProduct else {
            errorMessage = "pw_unavailable".localized
            return false
        }

        isLoading = true
        do {
            let result = try await product.purchase()
            isLoading = false

            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await updatePurchaseStatus()
                await transaction.finish()
                print("🎉 LifeSync AI Pro sbloccato con acquisto unico!")
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
            errorMessage = error.localizedDescription
            return false
        }
    }

    /// Ripristina gli acquisti dell'utente
    @MainActor
    func restorePurchases() async {
        isLoading = true
        do {
            try await AppStore.sync()
            await updatePurchaseStatus()
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }

    /// Verifica se l'utente possiede già l'acquisto Pro non consumabile.
    @MainActor
    func updatePurchaseStatus() async {
        var hasPro = false

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                if transaction.productID == PurchaseManager.proProductID && transaction.revocationDate == nil {
                    hasPro = true
                }
            } catch {
                print("⚠️ Errore verifica transazione: \(error)")
            }
        }

        self.isPro = hasPro
    }

    /// Ascolta nuove transazioni (es. acquisto completato dalla famiglia, ripristino automatico)
    private func listenForTransactions() -> Task<Void, Error> {
        return Task.detached {
            for await result in Transaction.updates {
                do {
                    let transaction = try self.checkVerified(result)
                    await self.updatePurchaseStatus()
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
