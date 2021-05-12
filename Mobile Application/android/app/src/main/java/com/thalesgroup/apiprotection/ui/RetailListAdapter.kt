package com.thalesgroup.apiprotection.ui

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.RecyclerView
import com.thalesgroup.apiprotection.R
import com.thalesgroup.apiprotection.databinding.RetailCardviewBinding
import com.thalesgroup.apiprotection.restapi.Shop
import com.thalesgroup.apiprotection.restapi.Warehouse

class RetailListAdapter(
    private val context: Context,
    private val dataSet: RetailLocations,
    val fragment: RetailListFragment) :
    RecyclerView.Adapter<RetailListAdapter.RetailHolder>() {


    sealed class RetailLocations {
        data class Warehouses(var retailList: MutableList<Warehouse>) : RetailLocations()
        data class Shops(var retailList: MutableList<Shop>) : RetailLocations()
        fun size(): Int {
            return when (this) {
                is Warehouses -> retailList.size
                is Shops -> retailList.size
            }
        }
    }


    /**
     * Provide a reference to the type of views that you are using
     * (custom ViewHolder).
     */
    class RetailHolder(val fragment: RetailListFragment, view: View) : RecyclerView.ViewHolder(view) {

        private val binding = RetailCardviewBinding.bind(view)
        private lateinit var retailId: String

        fun bind(shop: Shop, context: Context) {
            this.retailId = shop.id
            binding.storeCardTitle.text = shop.name
            binding.storeCardDescription.text = shop.description
            binding.storeCardCancelButton.visibility = View.GONE
            val banner = AppCompatResources.getDrawable(context, R.drawable.store_card_banner)
            binding.storeCardBanner.setImageDrawable(banner)
            binding.storeCardViewButton.setOnClickListener {
                val action = RetailListFragmentDirections.actionRetailListFragmentToProductListFragment(shop.id, true)
                fragment.findNavController().navigate(action)
            }
        }

        fun bind(warehouse: Warehouse, context: Context) {
            binding.storeCardTitle.text = warehouse.name
            binding.storeCardDescription.text = warehouse.description
            binding.storeCardCancelButton.visibility = View.GONE
            val banner = AppCompatResources.getDrawable(context, R.drawable.warehouse_card_banner)
            binding.storeCardBanner.setImageDrawable(banner)
            binding.storeCardViewButton.setOnClickListener {
                val action = RetailListFragmentDirections.actionRetailListFragmentToProductListFragment(warehouse.id, false)
                fragment.findNavController().navigate(action)
            }
        }

    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): RetailHolder {
        val view = LayoutInflater.from(viewGroup.context)
            .inflate(R.layout.retail_cardview, viewGroup, false)
        return RetailHolder(fragment, view)
    }

    override fun onBindViewHolder(viewHolder: RetailHolder, position: Int) {
        when (dataSet) {
            is RetailLocations.Warehouses -> viewHolder.bind(dataSet.retailList[position], context)
            is RetailLocations.Shops -> viewHolder.bind(dataSet.retailList[position], context)
        }
    }

    override fun getItemCount(): Int {
        return dataSet.size()
    }

    fun submitStores(shops: List<Shop>) {
        when (dataSet) {
            is RetailLocations.Shops -> {
                dataSet.retailList.clear()
                dataSet.retailList.addAll(shops)
                notifyDataSetChanged()
            }
            else -> {
                // Should not have been called.
            }
        }
    }

    fun submitWarehouses(warehouses: List<Warehouse>) {
        when (dataSet) {
            is RetailLocations.Warehouses -> {
                dataSet.retailList.clear()
                dataSet.retailList.addAll(warehouses)
                notifyDataSetChanged()
            }
            else -> {
                // Should not have been called.
            }
        }
    }

}
