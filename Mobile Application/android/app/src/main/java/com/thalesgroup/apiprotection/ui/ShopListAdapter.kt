package com.thalesgroup.apiprotection.ui

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.recyclerview.widget.RecyclerView
import com.thalesgroup.apiprotection.R
import com.thalesgroup.apiprotection.databinding.ItemShopBinding
import com.thalesgroup.apiprotection.restapi.Shop

class ShopListAdapter(private val context: Context, private val dataSet: MutableList<Shop>) :
    RecyclerView.Adapter<ShopListAdapter.ShopHolder>() {

    var selectedPos = RecyclerView.NO_POSITION


    class ShopHolder(view: View) : RecyclerView.ViewHolder(view), View.OnClickListener {

        private val binding = ItemShopBinding.bind(view)
        private lateinit var adapter: ShopListAdapter
        private lateinit var shop: Shop

        fun bind(shop: Shop, context: Context, adapter: ShopListAdapter) {
            this.shop = shop
            this.adapter = adapter
            binding.root.setOnClickListener(this)
            binding.shopNameField.text = shop.name
            binding.shopNameDescription.text = shop.description
        }

        override fun onClick(p0: View) {
            adapter.notifyItemChanged(adapter.selectedPos)
            adapter.selectedPos = layoutPosition
            adapter.notifyItemChanged(adapter.selectedPos)
        }
    }

    fun getSelectedShop(): Shop? {
        return dataSet.getOrNull(selectedPos)
    }

    fun submitProducts(newData: List<Shop>) {
        dataSet.clear()
        dataSet.addAll(newData)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ShopHolder {
        val view = LayoutInflater.from(viewGroup.context).inflate(R.layout.item_shop, viewGroup, false)
        return ShopHolder(view)
    }

    override fun onBindViewHolder(viewHolder: ShopHolder, position: Int) {
        viewHolder.bind(dataSet[position], context, this)
        viewHolder.itemView.isSelected = selectedPos == position
    }

    override fun getItemCount(): Int {
        return dataSet.size
    }

}
