package com.thalesgroup.gartnersample.ui

import android.os.Bundle
import androidx.fragment.app.activityViewModels
import androidx.navigation.fragment.findNavController
import androidx.preference.Preference
import androidx.preference.PreferenceFragmentCompat
import com.thalesgroup.gartnersample.R
import com.thalesgroup.gartnersample.model.RetailViewModel

class ConfigFragment: PreferenceFragmentCompat() {

    private val viewModel: RetailViewModel by activityViewModels()

    companion object {
        const val PREF_LOGIN = "pref_login_hint"
        const val PREF_SERVER_URL = "pref_server_url"

        const val PREF_RETAIL_CLIENT_SECRET = "pref_retail_client_secret"
        const val PREF_RETAIL_CLIENT_ID = "pref_retail_client_id"
        const val PREF_RETAIL_WELLKNOWN = "pref_retail_wellknown"

        const val PREF_PUBLIC_CLIENT_ID = "pref_public_client_id"
        const val PREF_PUBLIC_CLIENT_SECRET = "pref_public_client_secret"
        const val PREF_PUBLIC_WELLKNOWN = "pref_public_wellknown"

        const val PREF_OAUTH_INFO = "pref_oauth_info"
        const val PREF_RESET = "pref_reset_server"
        const val PREF_HAS_INITIALIZED = "pref_has_initialized"
    }

    override fun onCreatePreferences(savedInstanceState: Bundle?, rootKey: String?) {
        setPreferencesFromResource(R.xml.preferences, rootKey)
        this.findPreference<Preference>(PREF_RESET)?.setOnPreferenceClickListener {
            viewModel.resetServer {
            }
            true
        }
        this.findPreference<Preference>(PREF_OAUTH_INFO)?.setOnPreferenceClickListener {
            findNavController().navigate(ConfigFragmentDirections.actionNavConfigurationToOAuthFragment())
            true
        }
    }

}