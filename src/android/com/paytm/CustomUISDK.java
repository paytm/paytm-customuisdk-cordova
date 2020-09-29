
package com.paytm;

import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.Intent;
import android.text.TextUtils;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;

import androidx.appcompat.view.ContextThemeWrapper;

import com.android.volley.VolleyError;
import com.google.gson.Gson;

import net.one97.paytm.nativesdk.PaytmSDK;
import net.one97.paytm.nativesdk.Utils.Server;
import net.one97.paytm.nativesdk.app.PaytmSDKCallbackListener;
import net.one97.paytm.nativesdk.common.Constants.SDKConstants;
import net.one97.paytm.nativesdk.common.widget.PaytmConsentCheckBox;
import net.one97.paytm.nativesdk.dataSource.models.CardRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.NetBankingRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.UpiCollectRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.UpiDataRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.UpiIntentRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.UpiPushRequestModel;
import net.one97.paytm.nativesdk.dataSource.models.WalletRequestModel;
import net.one97.paytm.nativesdk.instruments.upicollect.models.UpiOptionsModel;
import net.one97.paytm.nativesdk.paymethods.datasource.PaymentMethodDataSource;
import net.one97.paytm.nativesdk.transcation.model.TransactionInfo;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaInterface;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.CordovaWebView;
import org.apache.cordova.PluginResult;
import org.jetbrains.annotations.Nullable;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import java.util.ArrayList;

import io.ionic.starter.R;

public class CustomUISDK extends CordovaPlugin implements PaytmSDKCallbackListener {
    private static final String TAG = "CustomUISDK";

    private static final int BALANCE_REQUEST_CODE = 102;
    private static final int SET_MPIN_REQUEST_CODE = 101;
    private static final int UPI_PUSH_REQUEST_CODE = 100;

    private CordovaInterface cordova;
    private Context mContext;
    private CallbackContext callbackContext;
    private PaytmSDK paytmSDK;


    public void initialize(CordovaInterface cordova, CordovaWebView webView) {
        super.initialize(cordova, webView);
        this.webView = webView;
        this.cordova = cordova;
        mContext = cordova.getContext();
        cordova.setActivityResultCallback(this);
        Log.d(TAG, "Initializing CustomUISDK");
    }

    public boolean execute(String action, JSONArray args, final CallbackContext callbackContext) throws JSONException {
        this.callbackContext = callbackContext;
        switch (action) {
            case "fetchAuthCode":
                fetchAuthCode(getString(args.get(0)));
                return true;
            case "isPaytmAppInstalled":
                isPaytmAppInstalled();
                return true;
            case "checkHasInstrument":
                checkHasInstrument(getString(args.get(0)));
                return true;
            case "initPaytmSDK":
                initPaytmSDK(getString(args.get(0)), getString(args.get(1)), getString(args.get(2)), getString(args.get(3)), (boolean) args.get(4), getString(args.get(5)));
                return true;
            case "getEnvironment":
                getEnvironment();
                return true;
            case "setEnvironment":
                setEnvironment(getString(args.get(0)));
                return true;
            case "goForWalletTransaction":
                goForWalletTransaction(getString(args.get(0)));
                return true;
            case "goForNewCardTransaction":
                goForNewCardTransaction(getString(args.get(0)), getString(args.get(1)), getString(args.get(2)), getString(args.get(3)), getString(args.get(4)), getString(args.get(5)), getString(args.get(6)), getString(args.get(7)), getString(args.get(8)), (boolean) args.get(9));
                return true;
            case "goForSavedCardTransaction":
                goForSavedCardTransaction(getString(args.get(0)), getString(args.get(1)), getString(args.get(2)), getString(args.get(3)), getString(args.get(4)), getString(args.get(5)), getString(args.get(6)), getString(args.get(7)));
                return true;
            case "goForNetBankingTransaction":
                goForNetBankingTransaction(getString(args.get(0)), getString(args.get(1)));
                return true;
            case "goForUpiCollectTransaction":
                goForUpiCollectTransaction(getString(args.get(0)), getString(args.get(1)), (boolean) args.get(2));
                return true;
            case "getUpiIntentList":
                getUpiIntentList();
                return true;
            case "goForUpiIntentTransaction":
                goForUpiIntentTransaction(getString(args.get(0)), getString(args.get(1)));
                return true;
            case "goForUpiPushTransaction":
                goForUpiPushTransaction(getString(args.get(0)), args.getJSONObject(1), getString(args.get(2)), args.getJSONObject(3));
                return true;
            case "fetchUpiBalance":
                fetchUpiBalance(args.getJSONObject(0), getString(args.get(1)));
                return true;
            case "setUpiMpin":
                setUpiMpin(args.getJSONObject(0), getString(args.get(1)));
                return true;
            case "getBin":
                getBin(getString(args.get(0)), getString(args.get(1)), getString(args.get(2)), getString(args.get(3)), getString(args.get(4)));
                return true;
            case "fetchNBList":
                fetchNBList(getString(args.get(0)), getString(args.get(1)), getString(args.get(2)), getString(args.get(3)), getString(args.get(4)));
                return true;
            case "fetchEmiDetails":
                fetchEmiDetails(getString(args.get(0)), getString(args.get(1)));
                return true;
            case "getLastNBSavedBank":
                getLastNBSavedBank();
                return true;
            case "getLastSavedVPA":
                getLastSavedVPA();
                return true;
            case "isAuthCodeValid":
                isAuthCodeValid(getString(args.get(0)), getString(args.get(1)));
                return true;
            default:
                return false;
        }
    }


    private void fetchAuthCode(String clientId) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(clientId, "Client id cannot be null");
                LayoutInflater inflater = cordova.getActivity().getLayoutInflater();
                View view = inflater.inflate(R.layout.custom_layout, null, true);
                PaytmConsentCheckBox checkBox = view.findViewById(R.id.consentCheckbox);
                AlertDialog.Builder builder = new AlertDialog.Builder(new ContextThemeWrapper(mContext, android.R.style.Theme_Material_Light_Dialog_Alert));
                builder.setView(view)
                        .setCancelable(false)
                        .setPositiveButton("ok", (dialog, id) -> {
                            if (checkBox.isChecked()) {
                                fetchAuthCode(clientId, dialog);
                            }
                        });
                AlertDialog dialog = builder.create();
                dialog.show();
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void fetchAuthCode(String clientId, DialogInterface dialogInterface) {
        try {
            if (PaytmSDK.getPaymentsUtilRepository().isPaytmAppInstalled(mContext)) {
                String authCode = PaytmSDK.getPaymentsUtilRepository().fetchAuthCode(cordova.getActivity(), clientId);
                if (authCode == null) {
                    setResult("Error accessing auth code", true);
                } else {
                    JSONObject object = new JSONObject();
                    object.put("response", authCode);
                    setResult(object, false);
                }
            } else {
                setResult("App not installed", true);
            }
        } catch (Exception e) {
            setResult(e.getMessage(), true);
        }
        dialogInterface.dismiss();
    }

    private void initPaytmSDK(String mid, String orderId, String txnToken, String amount, boolean isStaging, String callbackUrl) {
        cordova.getThreadPool().execute(() -> {
            try {
                checkNull(mid, "Merchant id cannot be null");
                checkNull(orderId, "Order id cannot be null");
                checkNull(txnToken, "Transaction token cannot be null");
                checkNull(amount, "Amount cannot be null");

                PaytmSDK.Builder builder =
                        new PaytmSDK.Builder(
                                mContext,
                                mid,
                                orderId,
                                txnToken,
                                java.lang.Double.parseDouble(amount),
                                this
                        );

                if (callbackUrl != null && !callbackUrl.equals("null") && !callbackUrl.isEmpty()) {
                    builder.setMerchantCallbackUrl(callbackUrl);
                }

                if (isStaging) {
                    PaytmSDK.setServer(Server.STAGING);
                } else {
                    PaytmSDK.setServer(Server.PRODUCTION);
                }

                paytmSDK = builder.build();
                setResult("Paytm sdk initialized successfully", false);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        });
    }

    private void isPaytmAppInstalled() {
        cordova.getThreadPool().execute(() -> {
            try {
                setResult(PaytmSDK.getPaymentsUtilRepository().isPaytmAppInstalled(cordova.getContext()));
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        });

    }

    private void getEnvironment() {
        cordova.getThreadPool().execute(() -> {
            try {
                setResult(PaytmSDK.server.toString(), false);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        });
    }

    private void setEnvironment(String environment) {
        cordova.getThreadPool().execute(() -> {
            try {
                checkNull(environment, "Environment cannot be null");

                if (environment.equalsIgnoreCase("STAGING")) {
                    PaytmSDK.setServer(Server.STAGING);
                } else if (environment.equalsIgnoreCase("PRODUCTION")) {
                    PaytmSDK.setServer(Server.PRODUCTION);
                }

            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        });

    }

    private void checkHasInstrument(String mid) {
        cordova.getThreadPool().execute(() -> {
            try {
                checkNull(mid, "Merchant id cannot be null");

                boolean hasInstrument = PaytmSDK.getPaymentsUtilRepository().userHasSavedInstruments(mContext, mid);
                setResult(hasInstrument);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        });

    }


    private void goForWalletTransaction(String paymentFlow) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(paymentFlow, "Payment Flow cannot be null");

                WalletRequestModel paymentRequestModel = new WalletRequestModel(paymentFlow);
                paytmSDK.startTransaction(mContext, paymentRequestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));

    }

    private void fetchEmiDetails(String channelCode, String cardType) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(channelCode, "Channel code cannot be null");
                checkNull(cardType, "CardType cannot be null");

                if (!channelCode.isEmpty()) {
                    PaytmSDK.getPaymentsHelper().getEMIDetails(mContext, channelCode, cardType, new PaymentMethodDataSource.Callback<JSONObject>() {
                        @Override
                        public void onResponse(@Nullable JSONObject response) {
                            setResult(response, false);
                        }

                        @Override
                        public void onErrorResponse(@Nullable VolleyError volleyError, @Nullable JSONObject object) {
                            setResult(object, true);
                        }
                    });
                } else {
                    setResult("Error fetching emi details", true);
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForNewCardTransaction(String cardNumber, String cardExpiry, String cardCvv, String cardType, String paymentFlow, String channelCode, String issuingBankCode, String emiChannelId, String authMode, boolean saveCard) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(cardNumber, "Card Number cannot be null");
                checkNull(cardExpiry, "Card Expiry cannot be null");
                checkNull(cardCvv, "Card Cvv cannot be null");
                checkNull(cardType, "Card Type cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");
                checkNull(channelCode, "Channel Code cannot be null");
                checkNull(issuingBankCode, "Issuing back code cannot be null");

                String authModeFinal = authMode;
                if (authModeFinal == null) {
                    authModeFinal = "otp";
                }

                CardRequestModel cardRequestModel = new CardRequestModel(
                        cardType,
                        paymentFlow,
                        cardNumber,
                        null,
                        cardCvv,
                        cardExpiry,
                        issuingBankCode,
                        channelCode,
                        authModeFinal,
                        emiChannelId,
                        saveCard);
                paytmSDK.startTransaction(mContext, cardRequestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForSavedCardTransaction(String cardId, String cardCvv, String cardType, String paymentFlow, String channelCode, String issuingBankCode, String emiChannelId, String authMode) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(cardId, "Card id cannot be null");
                checkNull(cardCvv, "Card Cvv cannot be null");
                checkNull(cardType, "Card Type cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");
                checkNull(channelCode, "Channel Code cannot be null");
                checkNull(issuingBankCode, "Issuing back code cannot be null");
                String authModeFinal = authMode;
                if (authModeFinal == null) {
                    authModeFinal = "otp";
                }

                CardRequestModel cardRequestModel = new CardRequestModel(
                        cardType,
                        paymentFlow,
                        null,
                        cardId,
                        cardCvv,
                        null,
                        issuingBankCode,
                        channelCode,
                        authModeFinal,
                        emiChannelId,
                        true);
                paytmSDK.startTransaction(mContext, cardRequestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForNetBankingTransaction(String netBankingCode, String paymentFlow) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(netBankingCode, "Net banking code cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");

                NetBankingRequestModel model = new NetBankingRequestModel(paymentFlow, netBankingCode);
                paytmSDK.startTransaction(mContext, model);

            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForUpiCollectTransaction(String upiCode, String paymentFlow, boolean saveVPA) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(upiCode, "UPI code cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");

                UpiCollectRequestModel model = new UpiCollectRequestModel(paymentFlow, upiCode, saveVPA);
                paytmSDK.startTransaction(mContext, model);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void getUpiIntentList() {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                ArrayList<UpiOptionsModel> upiIntentList = PaytmSDK.getPaymentsHelper().getUpiAppsInstalled(mContext);
                JSONArray array = new JSONArray();
                for (UpiOptionsModel item : upiIntentList) {
                    JSONObject jsonObject = new JSONObject();
                    jsonObject.put("appName", item.getAppName());
                    array.put(jsonObject);
                }
                JSONObject object = new JSONObject();
                object.put("list", array);
                setResult(object, false);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForUpiIntentTransaction(String appName, String paymentFlow) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(appName, "App name cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");

                ArrayList<UpiOptionsModel> upiIntentList = PaytmSDK.getPaymentsHelper().getUpiAppsInstalled(mContext);
                UpiOptionsModel model = null;
                for (UpiOptionsModel item : upiIntentList) {
                    if (appName.equals(item.getAppName())) {
                        model = item;
                        break;
                    }
                }

                if (model != null) {
                    UpiIntentRequestModel upiIntentDataRequestModel = new UpiIntentRequestModel(
                            paymentFlow,
                            model.getAppName(),
                            model.getResolveInfo().activityInfo
                    );

                    paytmSDK.startTransaction(mContext, upiIntentDataRequestModel);
                } else {
                    setResult("No upi intent of " + appName + " name found", true);
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void goForUpiPushTransaction(String paymentFlow, JSONObject bankAccountJson, String vpaName, JSONObject merchantDetailsJson) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {

            try {
                checkNull(bankAccountJson, "Bank Account object cannot be null");
                checkNull(paymentFlow, "Payment Flow cannot be null");
                checkNull(vpaName, "vpa cannot be null");
                checkNull(merchantDetailsJson, "Merchant Detail object cannot be null");

                UpiPushRequestModel upiPushRequestModel = new UpiPushRequestModel(paymentFlow, vpaName, bankAccountJson.toString(), merchantDetailsJson.toString(), UPI_PUSH_REQUEST_CODE);

                paytmSDK.startTransaction(mContext, upiPushRequestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void fetchUpiBalance(JSONObject bankAccountJson, String vpaName) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {

            try {
                checkNull(bankAccountJson, "Bank Account object cannot be null");
                checkNull(vpaName, "vpa cannot be null");

                UpiDataRequestModel requestModel = new UpiDataRequestModel(vpaName, bankAccountJson.toString(), BALANCE_REQUEST_CODE);
                paytmSDK.fetchUpiBalance(mContext, requestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void setUpiMpin(JSONObject bankAccountJson, String vpaName) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {

            try {
                checkNull(bankAccountJson, "Bank Account object cannot be null");
                checkNull(vpaName, "vpa cannot be null");

                UpiDataRequestModel requestModel = new UpiDataRequestModel(vpaName, bankAccountJson.toString(), SET_MPIN_REQUEST_CODE);
                paytmSDK.setUpiMpin(mContext, requestModel);
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void getBin(String cardSixDigit, String tokenType, String token, String mid, String referenceId) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(cardSixDigit, "Card digit cannot be null");
                checkNull(tokenType, "Token type cannot be null");
                checkNull(token, "Token cannot be null");
                checkNull(mid, "Merchant id cannot be null");

                if (tokenType.equalsIgnoreCase(SDKConstants.ACCESS)) {

                    checkNull(referenceId, "Reference id cannot be null");

                    PaytmSDK.getPaymentsHelper().fetchBinDetails(cardSixDigit, token, tokenType, mid, referenceId, new PaymentMethodDataSource.Callback<JSONObject>() {
                        @Override
                        public void onResponse(@Nullable JSONObject response) {
                            setResult(response, false);
                        }

                        @Override
                        public void onErrorResponse(@Nullable VolleyError volleyError, @Nullable JSONObject errorInfo) {
                            setResult(errorInfo, true);
                        }
                    });
                } else {
                    PaytmSDK.getPaymentsHelper().fetchBinDetails(cardSixDigit, token, tokenType, mid, "", new PaymentMethodDataSource.Callback<JSONObject>() {
                        @Override
                        public void onResponse(@Nullable JSONObject response) {
                            setResult(response, false);
                        }

                        @Override
                        public void onErrorResponse(@Nullable VolleyError volleyError, @Nullable JSONObject errorInfo) {
                            setResult(errorInfo, true);
                        }
                    });
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void fetchNBList(String tokenType, String token, String mid, String orderId, String referenceId) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(tokenType, "Token type cannot be null");
                checkNull(token, "Token cannot be null");
                checkNull(mid, "Merchant id cannot be null");

                if (tokenType.equals(SDKConstants.ACCESS)) {
                    checkNull(referenceId, "Reference id cannot be null");

                    PaytmSDK.getPaymentsHelper().getNBList(mid, tokenType, token, referenceId, new PaymentMethodDataSource.Callback<JSONObject>() {
                        @Override
                        public void onResponse(@Nullable JSONObject response) {
                            setResult(response, false);
                        }

                        @Override
                        public void onErrorResponse(@Nullable VolleyError volleyError, @Nullable JSONObject errorInfo) {
                            setResult(errorInfo, true);
                        }

                    });
                } else {
                    checkNull(orderId, "Order id cannot be null");

                    PaytmSDK.getPaymentsHelper().getNBList(mid, tokenType, token, orderId, new PaymentMethodDataSource.Callback<JSONObject>() {
                        @Override
                        public void onResponse(@Nullable JSONObject response) {
                            setResult(response, false);
                        }

                        @Override
                        public void onErrorResponse(@Nullable VolleyError volleyError, @Nullable JSONObject errorInfo) {
                            setResult(errorInfo, true);
                        }
                    });
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void getLastNBSavedBank() {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                String bank = PaytmSDK.getPaymentsUtilRepository().getLastNBSavedBank();
                if (bank != null && !bank.isEmpty()) {
                    setResult(bank, false);
                } else {
                    setResult("No Saved Bank Found", true);
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void getLastSavedVPA() {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                String vpa = PaytmSDK.getPaymentsUtilRepository().getLastSavedVPA();
                if (vpa != null && !vpa.isEmpty()) {
                    setResult(vpa, false);
                } else {
                    setResult("No Saved VPA Found", true);
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    private void isAuthCodeValid(String clientId, String authCode) {
        cordova.getThreadPool().execute(() -> cordova.getActivity().runOnUiThread(() -> {
            try {
                checkNull(clientId, "Client id cannot be null");
                checkNull(authCode, "AuthCode id cannot be null");

                Boolean isValid = PaytmSDK.getPaymentsUtilRepository().isValidAuthCode(mContext, clientId, authCode);
                if (isValid != null) {
                    setResult(isValid);
                }
            } catch (Exception e) {
                setResult(e.getMessage(), true);
            }
        }));
    }

    @Override
    public void onTransactionResponse(TransactionInfo p0) {
        try {
            if (p0 != null) {
                String s = new Gson().toJson(p0.getTxnInfo());
                if (s != null) {
                    JSONObject object = new JSONObject(s);
                    while (object.has("nameValuePairs")) {
                        object = object.getJSONObject("nameValuePairs");
                    }
                    setResult(object, false);
                } else {
                    setResult("null", true);
                }
            } else {
                setResult("null", true);
            }
        } catch (Exception e) {
            setResult(e.getMessage(), true);
        }
        finish();
    }

    @Override
    public void networkError() {
        setResult("networkError", true);
        finish();
    }

    @Override
    public void onBackPressedCancelTransaction() {
        setResult("onBackPressedCancelTransaction", true);
        finish();
    }

    @Override
    public void onGenericError(int i, String s) {
        setResult("onGenericError " + i + " " + s, true);
        finish();
    }

    private void finish() {
        paytmSDK.clear();
        paytmSDK = null;
        callbackContext = null;
    }

    private void setResult(String message, boolean isError) {
        if (callbackContext != null) {
            PluginResult result;
            if (isError) {
                result = new PluginResult(PluginResult.Status.ERROR, message);

            } else {
                result = new PluginResult(PluginResult.Status.OK, message);
            }
            callbackContext.sendPluginResult(result);
        }
    }

    private void setResult(boolean message) {
        if (callbackContext != null) {
            PluginResult result;
            result = new PluginResult(PluginResult.Status.OK, message);
            callbackContext.sendPluginResult(result);
        }
    }

    private void setResult(JSONObject message, boolean isError) {
        if (callbackContext != null) {
            PluginResult result;
            if (isError) {
                result = new PluginResult(PluginResult.Status.ERROR, message);

            } else {
                result = new PluginResult(PluginResult.Status.OK, message);
            }
            callbackContext.sendPluginResult(result);
        }
    }

    private String getString(Object object) {
        if (object != null) {
            String val = object.toString();
            if (!val.equals("null")) {
                return val;
            }
        }
        return null;
    }

    @Override
    public void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        cordova.setActivityResultCallback(this);
        try {
            if (requestCode == UPI_PUSH_REQUEST_CODE && data != null) {
                String message = data.getStringExtra("nativeSdkForMerchantMessage");
                String response = data.getStringExtra("response");
                if (message != null && !message.isEmpty()) {
                    setResult(message, true);
                } else if (response != null && !response.isEmpty()) {
                    setResult(new JSONObject(response), false);
                } else {
                    setResult("Response is Empty", true);
                }
                finish();
            } else if (requestCode == SET_MPIN_REQUEST_CODE && data != null) {
                String response = data.getStringExtra("response");
                if (response != null && !response.isEmpty()) {
                    setResult(new JSONObject(response), false);
                } else {
                    setResult("Response is Empty", true);
                }
            } else if (requestCode == BALANCE_REQUEST_CODE && data != null) {
                String response = data.getStringExtra("response");
                if (response != null && !response.isEmpty()) {
                    setResult(new JSONObject(response), false);
                } else {
                    setResult("Response is Empty", true);
                }
            } else if (requestCode == SDKConstants.REQUEST_CODE_UPI_APP) {
                if (data != null) {
                    String status = data.getStringExtra("Status");
                    if (status != null && !TextUtils.isEmpty(status) && status.equalsIgnoreCase("FAILURE")) {
                        setResult("Transaction failed", true);
                        finish();
                    } else {
                        PaytmSDK.getPaymentsHelper().makeUPITransactionStatusRequest(mContext, "NONE");
                    }
                } else {
                    PaytmSDK.getPaymentsHelper().makeUPITransactionStatusRequest(mContext, "NONE");
                }
            }
        } catch (Exception e) {
            setResult(e.getMessage(), true);
        }
    }

    private void checkNull(String value, String message) throws NullPointerException {
        if (value == null) {
            throw new NullPointerException(message);
        }
    }

    private void checkNull(JSONObject value, String message) throws NullPointerException {
        if (value == null) {
            throw new NullPointerException(message);
        }
    }


}
