package com.konechoco.lifesyncai

import android.app.Application
import com.konechoco.lifesyncai.ads.AdsManager
import com.konechoco.lifesyncai.billing.BillingManager
import com.konechoco.lifesyncai.data.Store
import com.konechoco.lifesyncai.notifications.NightlyReminder

class LifeSyncApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Store.init(this)
        BillingManager.init(this)
        AdsManager.init(this)
        NightlyReminder.createChannel(this)
        NightlyReminder.scheduleFromSettings(this)
    }
}
