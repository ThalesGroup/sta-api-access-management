package com.thalesgroup.gartnersample.ui

import android.content.Context
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import androidx.appcompat.content.res.AppCompatResources
import androidx.navigation.fragment.findNavController
import androidx.recyclerview.widget.RecyclerView
import com.thalesgroup.gartnersample.R
import com.thalesgroup.gartnersample.databinding.ItemProductBinding
import com.thalesgroup.gartnersample.restapi.StockItem

class ProductListAdapter(
    private val context: Context,
    private val dataSet: MutableList<StockItem>,
    private val isWarehouse: Boolean,
    val retailId: String,
    val fragment: ProductListFragment) :
    RecyclerView.Adapter<ProductListAdapter.ProductHolder>() {


    /**
     * Provide a reference to the type of views that you are using
     * (custom ViewHolder).
     */
    class ProductHolder(val fragment: ProductListFragment, val retailId: String, view: View) : RecyclerView.ViewHolder(view) {

        private val binding = ItemProductBinding.bind(view)
        private lateinit var stock: StockItem

        fun bind(stock: StockItem, showMove: Boolean, context: Context) {
            this.stock = stock
            binding.productName.text = stock.name
            binding.productDescription.text = stock.description
            if (stock.count > 0) {
                binding.productStatusInfo.text = context.getString(R.string.stock_quantity, stock.count)
                val icon = AppCompatResources.getDrawable(context, R.drawable.ic_baseline_check_circle_24)
                binding.productStatusIcon.setImageDrawable(icon)
            } else {
                binding.productStatusInfo.text = context.getString(R.string.stock_unavailable)
                val icon = AppCompatResources.getDrawable(context, R.drawable.ic_baseline_remove_circle_24)
                binding.productStatusIcon.setImageDrawable(icon)
            }
            if (showMove) {
                binding.moveButton.setOnClickListener {
                    val action =
                        ProductListFragmentDirections.actionProductListFragmentToMoveStockFragment(
                            retailId,
                            stock.id
                        )
                    fragment.findNavController().navigate(action)
                }
            } else {
                binding.moveButton.visibility = View.INVISIBLE
            }
        }

    }

    fun submitProducts(newData: List<StockItem>) {
        dataSet.clear()
        dataSet.addAll(newData)
        notifyDataSetChanged()
    }

    override fun onCreateViewHolder(viewGroup: ViewGroup, viewType: Int): ProductHolder {
        val view = LayoutInflater.from(viewGroup.context)
            .inflate(R.layout.item_product, viewGroup, false)
        return ProductHolder(fragment, retailId, view)
    }

    override fun onBindViewHolder(viewHolder: ProductHolder, position: Int) {
        viewHolder.bind(dataSet[position], isWarehouse, context)
    }

    override fun getItemCount(): Int {
        return dataSet.size
    }

}
