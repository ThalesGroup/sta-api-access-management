package com.thalesgroup.apiprotection.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.thalesgroup.apiprotection.restapi.Status
import com.thalesgroup.apiprotection.databinding.FragmentRetailListBinding

class RetailListFragment: BaseFragment() {

    private lateinit var binding: FragmentRetailListBinding

    private lateinit var viewAdapter: RetailListAdapter
    private val args: RetailListFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?): View? {
        binding = FragmentRetailListBinding.inflate(inflater, container, false)

        val retailList = if (args.store) {
            observeShops()
            RetailListAdapter.RetailLocations.Shops(mutableListOf())
        } else {
            observeWarehouses()
            RetailListAdapter.RetailLocations.Warehouses(mutableListOf())
        }
        viewAdapter = RetailListAdapter(requireContext(), retailList, this)
        binding.retailList.apply {
            adapter = viewAdapter
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(activity)
        }
        return binding.root
    }


    private fun observeShops() {
        viewModel.fetchShopsWithInfo().observe(viewLifecycleOwner, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { shopList ->
                            viewAdapter.submitStores(shopList)
                        }
                        activity.hideLoadingBar()
                    }
                    Status.ERROR -> {
                        activity.handleError(resource.exception)
                        activity.hideLoadingBar()
                    }
                    Status.LOADING -> {
                        activity.showLongLoad()
                    }
                }
            }
        })
    }

    private fun observeWarehouses() {
        viewModel.fetchWarehousesWithInfo().observe(viewLifecycleOwner, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { warehouseList ->
                            viewAdapter.submitWarehouses(warehouseList)
                        }
                        activity.hideLoadingBar()
                    }
                    Status.ERROR -> {
                        activity.handleError(resource.exception)
                        activity.hideLoadingBar()
                    }
                    Status.LOADING -> {
                        activity.showLongLoad()
                    }
                }
            }
        })
    }

}