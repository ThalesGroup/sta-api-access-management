package com.thalesgroup.gartnersample.ui

import androidx.fragment.app.Fragment
import androidx.fragment.app.activityViewModels
import com.thalesgroup.gartnersample.model.RetailViewModel

/**
 * Base fragment class to provide utility access to the activity and viewModel
 */
open class BaseFragment: Fragment() {

    val activity get() = getActivity() as MainActivity
    val viewModel: RetailViewModel by activityViewModels()

}