package com.konechoco.lifesyncai.billing

import android.app.Activity
import android.content.Context
import android.util.Log
import androidx.core.content.edit
import com.android.billingclient.api.AcknowledgePurchaseParams
import com.android.billingclient.api.BillingClient
import com.android.billingclient.api.BillingClientStateListener
import com.android.billingclient.api.BillingFlowParams
import com.android.billingclient.api.BillingResult
import com.android.billingclient.api.PendingPurchasesParams
import com.android.billingclient.api.ProductDetails
import com.android.billingclient.api.Purchase
import com.android.billingclient.api.PurchasesUpdatedListener
import com.android.billingclient.api.QueryProductDetailsParams
import com.android.billingclient.api.QueryPurchasesParams
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow

/**
 * LifeSync AI Pro: acquisto unico (prodotto in-app non consumabile) di 3,99 € su Google Play.
 * Toglie la pubblicità e sblocca riepiloghi illimitati ed export CSV. Nessun abbonamento.
 */
object BillingManager : PurchasesUpdatedListener {
    const val PRO_PRODUCT_ID = "com.lifesync.ai.pro.onetime"
    private const val TAG = "LifeSyncBilling"
    private const val PREFS = "billing"

    private lateinit var appContext: Context
    private lateinit var client: BillingClient
    private var productDetails: ProductDetails? = null

    private val _isPro = MutableStateFlow(false)
    val isPro: StateFlow<Boolean> = _isPro.asStateFlow()

    private val _price = MutableStateFlow<String?>(null)
    val price: StateFlow<String?> = _price.asStateFlow()

    private val _pending = MutableStateFlow(false)
    val pending: StateFlow<Boolean> = _pending.asStateFlow()

    private val _message = MutableStateFlow<String?>(null)
    /** Errore da mostrare all'utente (null = nessun errore). */
    val message: StateFlow<String?> = _message.asStateFlow()

    fun init(context: Context) {
        appContext = context.applicationContext
        // Ultimo stato noto: l'app resta Pro anche senza rete finché Play non risponde.
        _isPro.value = prefs().getBoolean("isPro", false)
        client = BillingClient.newBuilder(appContext)
            .setListener(this)
            .enablePendingPurchases(PendingPurchasesParams.newBuilder().enableOneTimeProducts().build())
            .enableAutoServiceReconnection()
            .build()
        connect()
    }

    private fun connect() {
        client.startConnection(object : BillingClientStateListener {
            override fun onBillingSetupFinished(result: BillingResult) {
                if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                    queryProduct()
                    refreshPurchases()
                } else {
                    Log.w(TAG, "Billing non disponibile: ${result.debugMessage}")
                }
            }

            override fun onBillingServiceDisconnected() = Unit
        })
    }

    private fun queryProduct() {
        val params = QueryProductDetailsParams.newBuilder()
            .setProductList(
                listOf(
                    QueryProductDetailsParams.Product.newBuilder()
                        .setProductId(PRO_PRODUCT_ID)
                        .setProductType(BillingClient.ProductType.INAPP)
                        .build()
                )
            )
            .build()
        client.queryProductDetailsAsync(params) { result, detailsResult ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                productDetails = detailsResult.productDetailsList.firstOrNull()
                _price.value = productDetails?.oneTimePurchaseOfferDetails?.formattedPrice
            }
        }
    }

    /** Ripristino: legge gli acquisti già fatti con questo account Google. */
    fun refreshPurchases() {
        if (!client.isReady) return
        val params = QueryPurchasesParams.newBuilder().setProductType(BillingClient.ProductType.INAPP).build()
        client.queryPurchasesAsync(params) { result, purchases ->
            if (result.responseCode == BillingClient.BillingResponseCode.OK) {
                handlePurchases(purchases, fromQuery = true)
            }
        }
    }

    fun purchase(activity: Activity, unavailableMessage: String) {
        val details = productDetails
        if (details == null) {
            queryProduct()
            _message.value = unavailableMessage
            return
        }
        val params = BillingFlowParams.newBuilder()
            .setProductDetailsParamsList(
                listOf(BillingFlowParams.ProductDetailsParams.newBuilder().setProductDetails(details).build())
            )
            .build()
        client.launchBillingFlow(activity, params)
    }

    fun clearMessage() {
        _message.value = null
    }

    override fun onPurchasesUpdated(result: BillingResult, purchases: MutableList<Purchase>?) {
        when (result.responseCode) {
            BillingClient.BillingResponseCode.OK -> handlePurchases(purchases.orEmpty(), fromQuery = false)
            BillingClient.BillingResponseCode.ITEM_ALREADY_OWNED -> refreshPurchases()
            BillingClient.BillingResponseCode.USER_CANCELED -> Unit
            else -> _message.value = result.debugMessage.ifBlank { "Error ${result.responseCode}" }
        }
    }

    private fun handlePurchases(purchases: List<Purchase>, fromQuery: Boolean) {
        val pro = purchases.filter { PRO_PRODUCT_ID in it.products }
        val purchased = pro.firstOrNull { it.purchaseState == Purchase.PurchaseState.PURCHASED }
        _pending.value = pro.any { it.purchaseState == Purchase.PurchaseState.PENDING }
        if (purchased != null) {
            setPro(true)
            if (!purchased.isAcknowledged) {
                val params = AcknowledgePurchaseParams.newBuilder().setPurchaseToken(purchased.purchaseToken).build()
                client.acknowledgePurchase(params) { ack ->
                    Log.d(TAG, "acknowledge: ${ack.responseCode}")
                }
            }
        } else if (fromQuery) {
            // Nessun acquisto valido su questo account (anche dopo un rimborso)
            setPro(false)
        }
    }

    private fun setPro(value: Boolean) {
        _isPro.value = value
        prefs().edit { putBoolean("isPro", value) }
    }

    private fun prefs() = appContext.getSharedPreferences(PREFS, Context.MODE_PRIVATE)
}
