package com.thalesgroup.gartnersample.ui

import android.content.Context
import android.os.Bundle
import android.view.LayoutInflater
import android.view.View
import android.view.ViewGroup
import android.view.inputmethod.InputMethodManager
import android.widget.Toast
import androidx.appcompat.app.AlertDialog
import androidx.navigation.fragment.findNavController
import androidx.navigation.fragment.navArgs
import androidx.recyclerview.widget.LinearLayoutManager
import com.thalesgroup.gartnersample.R
import com.thalesgroup.gartnersample.databinding.FragmentMoveStockBinding
import com.thalesgroup.gartnersample.restapi.Status


class MoveStockFragment: BaseFragment() {

    private lateinit var binding: FragmentMoveStockBinding

    private lateinit var viewAdapter: ShopListAdapter
    private val args: MoveStockFragmentArgs by navArgs()

    override fun onCreateView(
            inflater: LayoutInflater, container: ViewGroup?,
            savedInstanceState: Bundle?): View? {
        binding = FragmentMoveStockBinding.inflate(inflater, container, false)

        val retailId = args.retailId
        val stockId = args.stockId

        viewModel.fetchShops().observe(viewLifecycleOwner, { it ->
            it?.let { resource ->
                when (resource.status) {
                    Status.SUCCESS -> {
                        resource.data?.let {
                            viewAdapter.submitProducts(it)
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

        viewAdapter = ShopListAdapter(requireContext(), mutableListOf())
        binding.shopList.apply {
            adapter = viewAdapter
            setHasFixedSize(true)
            layoutManager = LinearLayoutManager(activity)
        }
        binding.moveButton.setOnClickListener {
            val shopId =  viewAdapter.getSelectedShop()?.id
            if (shopId == null) {
                Toast.makeText(context, R.string.move_request_select_store, Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            val count = try {
                 Integer.parseInt(binding.countField.text.toString())
            } catch (ex: Exception) {
                Toast.makeText(context, R.string.move_request_enter_count, Toast.LENGTH_SHORT).show()
                return@setOnClickListener
            }
            activity.showLongLoad()
            viewModel.moveStock(stockId, count, retailId, shopId) {
                if (it == null) {
                    showSuccessDialog()
                } else {
                    showFailureDialog(it.message)
                }
                activity.hideLoadingBar()
            }
        }
        return binding.root
    }

    override fun onPause() {
        super.onPause()
        activity.window.currentFocus?.let { view ->
            val imm = activity.getSystemService(Context.INPUT_METHOD_SERVICE) as? InputMethodManager
            imm?.hideSoftInputFromWindow(view.windowToken, 0)
        }
    }

    private fun showFailureDialog(message: String?) {
        val builder = AlertDialog.Builder(requireContext())
        builder.setTitle(R.string.dialog_move_failure_title)
        builder.setIcon(R.drawable.ic_baseline_remove_circle_24)
        builder.setMessage(getString(R.string.dialog_move_failure_message, message))
        builder.setPositiveButton(R.string.dialog_move_failure_button) { _, _ -> }
        builder.show()
    }

    private fun showSuccessDialog() {
        val builder = AlertDialog.Builder(requireContext())
        builder.setTitle(R.string.dialog_move_success_title)
        builder.setIcon(R.drawable.ic_baseline_check_circle_24)
        builder.setMessage(R.string.dialog_move_success_message)
        builder.setOnDismissListener {
            findNavController().popBackStack()
        }
        builder.setPositiveButton(R.string.dialog_move_success_button) { _, _ -> }
        builder.show()
    }

}