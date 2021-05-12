package com.thalesgroup.apiprotection.ui

import android.os.Bundle
import android.view.*
import android.widget.Toast
import androidx.appcompat.content.res.AppCompatResources
import androidx.navigation.fragment.findNavController
import androidx.navigation.ui.NavigationUI
import com.google.android.gms.maps.CameraUpdateFactory
import com.google.android.gms.maps.GoogleMap
import com.google.android.gms.maps.OnMapReadyCallback
import com.google.android.gms.maps.model.BitmapDescriptorFactory
import com.google.android.gms.maps.model.Marker
import com.google.android.gms.maps.model.MarkerOptions
import com.google.android.material.tabs.TabLayout
import com.thalesgroup.apiprotection.R
import com.thalesgroup.apiprotection.databinding.FragmentMapsBinding
import com.thalesgroup.apiprotection.restapi.*


class MapsFragment : BaseFragment(), OnMapReadyCallback, GoogleMap.OnMarkerClickListener,
    TabLayout.OnTabSelectedListener {

    private lateinit var binding: FragmentMapsBinding

    private val mapView get() = binding.mapView
    private val warehouseMarkers = ArrayList<Marker>()
    private val shopMarkers = ArrayList<Marker>()
    private var googleMap: GoogleMap? = null

    override fun onCreateView(
            inflater: LayoutInflater,
            container: ViewGroup?,
            savedInstanceState: Bundle?): View? {
        binding = FragmentMapsBinding.inflate(inflater, container, false)
        mapView.onCreate(savedInstanceState)
        binding.tabs.addOnTabSelectedListener(this)
        return binding.root
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setHasOptionsMenu(true)
    }

    override fun onViewCreated(view: View, savedInstanceState: Bundle?) {
        super.onViewCreated(view, savedInstanceState)
        activity.showLongLoad()
        mapView.getMapAsync(this)
    }

    override fun onStart() {
        super.onStart()
        mapView.onStart()
    }

    override fun onResume() {
        super.onResume()
        mapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapView.onPause()
    }

    override fun onStop() {
        super.onStop()
        mapView.onStop()
    }

    override fun onDestroy() {
        super.onDestroy()
        mapView.onDestroy()
    }

    override fun onSaveInstanceState(outState: Bundle) {
        super.onSaveInstanceState(outState)
        mapView.onSaveInstanceState(outState)
    }

    override fun onLowMemory() {
        super.onLowMemory()
        mapView.onLowMemory()
    }

    override fun onMapReady(googleMap: GoogleMap) {
        googleMap.setOnMarkerClickListener(this)
        googleMap.uiSettings.isCompassEnabled = false
        googleMap.uiSettings.isMapToolbarEnabled = false
        activity.hideLoadingBar()
        this.googleMap = googleMap
        showRetailLocations(binding.tabs.selectedTabPosition)
    }

    override fun onMarkerClick(marker: Marker): Boolean {
        when {
            shopMarkers.contains(marker) -> {
                return onShopMarkerClicked(marker)
            }
            warehouseMarkers.contains(marker) -> {
                return onWarehouseMarkerClicked(marker)
            }
            else -> {
                Toast.makeText(activity, R.string.unknown_marker_clicked, Toast.LENGTH_LONG).show()
            }
        }
        return true
    }

    private fun onShopMarkerClicked(marker: Marker): Boolean {
        observeShopInfo(marker.tag.toString())
        return true
    }

    private fun onWarehouseMarkerClicked(marker: Marker): Boolean {
        observeWarehouseInfo(marker.tag.toString())
        return true
    }

    override fun onCreateOptionsMenu(menu: Menu, inflater:MenuInflater) {
        super.onCreateOptionsMenu(menu, inflater)
        inflater.inflate(R.menu.menu_main, menu)
    }
    override fun onTabSelected(tab: TabLayout.Tab) {
        googleMap ?: return
        showRetailLocations(tab.position)
    }

    private fun showRetailLocations(selectedPosition: Int) {
        if (selectedPosition == 0) {
            googleMap?.clear()
            warehouseMarkers.clear()
            observeShops()
        } else if (selectedPosition == 1) {
            googleMap?.clear()
            shopMarkers.clear()
            observeWarehouses()
        }
    }

    override fun onOptionsItemSelected(item: MenuItem): Boolean {
        if (item.itemId == R.id.action_list) {
            val areStoresSelected = binding.tabs.selectedTabPosition == 0
            val action = MapsFragmentDirections.actionNavMapToRetailListFragment(areStoresSelected)
            findNavController().navigate(action)
        }
        return NavigationUI.onNavDestinationSelected(item, findNavController()) || super.onOptionsItemSelected(item)
    }


    override fun onTabUnselected(tab: TabLayout.Tab) {

    }

    override fun onTabReselected(tab: TabLayout.Tab) {
    }


    private fun observeShops() {
        viewModel.fetchShops().observe(this, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { shops -> postShops(shops) }
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
        viewModel.fetchWarehouses().observe(this, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { warehouses -> postWarehouses(warehouses) }
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

    private fun observeShopInfo(shopId: String) {
        viewModel.fetchShopInfo(shopId).observe(this, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { shop -> postShopInfo(shop) }
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

    private fun observeWarehouseInfo(warehouseId: String) {
        viewModel.fetchWarehouseInfo(warehouseId).observe(this, {
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let { warehouse -> postWarehouseInfo(warehouse) }
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

    private fun postShopInfo(shop: ShopInfo) {
        binding.storeCard.root.visibility = View.VISIBLE
        binding.storeCard.storeCardTitle.text = shop.name
        binding.storeCard.storeCardDescription.text = shop.description
        binding.storeCard.storeCardCancelButton.setOnClickListener {
            binding.storeCard.root.visibility = View.GONE
        }
        val banner = AppCompatResources.getDrawable(requireContext(), R.drawable.store_card_banner)
        binding.storeCard.storeCardBanner.setImageDrawable(banner)
        binding.storeCard.storeCardViewButton.setOnClickListener {
            val action = MapsFragmentDirections.actionMapsFragmentToProductListFragment(shop.id, true)
            findNavController().navigate(action)
        }
    }

    private fun postWarehouseInfo(warehouse: WarehouseInfo) {
        binding.storeCard.root.visibility = View.VISIBLE
        binding.storeCard.storeCardTitle.text = warehouse.name
        binding.storeCard.storeCardDescription.text = warehouse.description
        binding.storeCard.storeCardCancelButton.setOnClickListener {
            binding.storeCard.root.visibility = View.GONE
        }
        val banner = AppCompatResources.getDrawable(requireContext(), R.drawable.warehouse_card_banner)
        binding.storeCard.storeCardBanner.setImageDrawable(banner)
        binding.storeCard.storeCardViewButton.setOnClickListener {
            val action = MapsFragmentDirections.actionMapsFragmentToProductListFragment(warehouse.id, false)
            findNavController().navigate(action)
        }
    }


    private fun postShops(shops: List<Shop>) {
        googleMap?.apply {
            clear()
            warehouseMarkers.clear()
            if (shops.isNotEmpty()) {
                moveCamera(
                    CameraUpdateFactory.newLatLngZoom(
                        shops.first().getLatLng(),
                        10.0f
                    )
                )
            }
            shops.forEach {
                val marker = addMarker(MarkerOptions().position(it.getLatLng()).title(it.name).icon(
                    BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_BLUE)))
                marker.tag = it.id
                shopMarkers.add(marker)
            }
        }
    }

    private fun postWarehouses(warehouses: List<Warehouse>) {
        googleMap?.apply {
            clear()
            shopMarkers.clear()
            if (warehouses.isNotEmpty()) {
                moveCamera(
                    CameraUpdateFactory.newLatLngZoom(
                        warehouses.first().getLatLng(),
                        10.0f
                    )
                )
            }
            warehouses.forEach {
                val marker = addMarker(
                    MarkerOptions().position(it.getLatLng()).title(it.name).icon(
                        BitmapDescriptorFactory.defaultMarker(BitmapDescriptorFactory.HUE_ORANGE)
                    )
                )
                marker.tag = it.id
                warehouseMarkers.add(marker)
            }
        }
    }
}