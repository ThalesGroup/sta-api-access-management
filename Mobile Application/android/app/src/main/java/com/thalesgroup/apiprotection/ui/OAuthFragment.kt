package com.thalesgroup.apiprotection.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import com.thalesgroup.apiprotection.R
import com.thalesgroup.apiprotection.databinding.FragmentOauthBinding
import java.util.concurrent.TimeUnit

class OAuthFragment: BaseFragment() {


    private lateinit var binding: FragmentOauthBinding

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?
    ): View? {
        // Inflate the layout for this fragment
        binding = FragmentOauthBinding.inflate(inflater, container, false)
        val authState = viewModel.authState ?: viewModel.publicAuthState
        if (authState == null) {
            binding.fieldAuthType.text = getString(R.string.oauth_unauthorized)
            binding.fieldIsAuthorized.text = false.toString()
            // No auth state at all
        } else {
            if (viewModel.authState != null) {
                binding.fieldAuthType.text = getString(R.string.oauth_authorized)
            } else {
                binding.fieldAuthType.text = getString(R.string.oauth_client_credentials)
            }
            binding.fieldAccessToken.text = authState.accessToken
            binding.fieldRefreshToken.text = authState.refreshToken
            binding.fieldIsAuthorized.text = authState.isAuthorized.toString()
            val expirationDiff = authState.accessTokenExpirationTime!! - System.currentTimeMillis()
            val seconds: Long = TimeUnit.MILLISECONDS.toSeconds(expirationDiff)
            binding.fieldExpirationTime.text =getString(R.string.oauth_expiration_seconds, seconds.toString())
        }
        return binding.root
    }

}