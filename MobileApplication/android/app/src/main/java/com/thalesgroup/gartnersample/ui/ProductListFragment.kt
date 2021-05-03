package com.thalesgroup.gartnersample.ui

import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.thalesgroup.gartnersample.restapi.Status
import com.thalesgroup.gartnersample.databinding.FragmentProductListBinding

class ProductListFragment: BaseFragment() {

    private lateinit var binding: FragmentProductListBinding

    private lateinit var viewAdapter: ProductListAdapter
    private val args: ProductListFragmentArgs by navArgs()

    override fun onCreateView(
        inflater: LayoutInflater, container: ViewGroup?,
        savedInstanceState: Bundle?): View? {
        binding = FragmentProductListBinding.inflate(inflater, container, false)

        if (args.store) {
            observeShops()
        } else {
           observeWarehouses()
        }

        viewAdapter = ProductListAdapter(requireContext(), mutableListOf(), !args.store, args.retailId, this)
        binding.productList.apply {
            adapter = viewAdapter
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(activity)
        }
        return binding.root
    }

    private fun observeShops() {
        viewModel.fetchShopStock(args.retailId).observe(viewLifecycleOwner, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { stockList ->
                            viewAdapter.submitProducts(stockList)
                        }
                        activity.hideLoadingBar()
                    }
                    Status.ERROR -> {
                        activity.handleError(resource.exception)
                        activity.hideLoadingBar()
                    }
                    Status.LOADING -> {
                        activity.showShortLoad()
                    }
                }
            }
        })
    }

    private fun observeWarehouses() {
        viewModel.fetchWarehouseStock(args.retailId).observe(viewLifecycleOwner, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { stockList ->
                            viewAdapter.submitProducts(stockList)
                        }
                        activity.hideLoadingBar()
                    }
                    Status.ERROR -> {
                        activity.handleError(resource.exception)
                        activity.hideLoadingBar()
                    }
                    Status.LOADING -> {
                        activity.showShortLoad()
                    }
                }
            }
        })
    }

}