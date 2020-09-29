const exec = require("cordova/exec");

const PLUGIN_NAME = "CustomUISDK";

const CustomUISDK = {
  fetchAuthCode: function (clientId, mid, success, error) {
    exec(success, error, PLUGIN_NAME, "fetchAuthCode", [clientId, mid]);
  },
  isPaytmAppInstalled: function (success, error) {
    exec(success, error, PLUGIN_NAME, "isPaytmAppInstalled", []);
  },
  checkHasInstrument: function (mid, success, error) {
    exec(success, error, PLUGIN_NAME, "checkHasInstrument", [mid]);
  },
  initPaytmSDK: function (
    mid,
    orderId,
    txnToken,
    amount,
    isStaging,
    callbackUrl,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "initPaytmSDK", [
      mid,
      orderId,
      txnToken,
      amount,
      isStaging,
      callbackUrl,
    ]);
  },

  goForWalletTransaction: function (paymentFlow, success, error) {
    exec(success, error, PLUGIN_NAME, "goForWalletTransaction", [paymentFlow]);
  },

  goForNewCardTransaction: function (
    cardNumber,
    cardExpiry,
    cardCvv,
    cardType,
    paymentFlow,
    channelCode,
    issuingBankCode,
    emiChannelId,
    authMode,
    saveCard,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "goForNewCardTransaction", [
      cardNumber,
      cardExpiry,
      cardCvv,
      cardType,
      paymentFlow,
      channelCode,
      issuingBankCode,
      emiChannelId,
      authMode,
      saveCard,
    ]);
  },
  goForSavedCardTransaction: function (
    cardId,
    cardCvv,
    cardType,
    paymentFlow,
    channelCode,
    issuingBankCode,
    emiChannelId,
    authMode,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "goForSavedCardTransaction", [
      cardId,
      cardCvv,
      cardType,
      paymentFlow,
      channelCode,
      issuingBankCode,
      emiChannelId,
      authMode,
    ]);
  },
  goForNetBankingTransaction: function (
    netBankingCode,
    paymentFlow,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "goForNetBankingTransaction", [
      netBankingCode,
      paymentFlow,
    ]);
  },
  goForUpiCollectTransaction: function (
    upiCode,
    paymentFlow,
    saveVPA,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "goForUpiCollectTransaction", [
      upiCode,
      paymentFlow,
      saveVPA,
    ]);
  },
  getUpiIntentList: function (success, error) {
    exec(success, error, PLUGIN_NAME, "getUpiIntentList", []);
  },
  goForUpiIntentTransaction: function (appName, paymentFlow, success, error) {
    exec(success, error, PLUGIN_NAME, "goForUpiIntentTransaction", [
      appName,
      paymentFlow,
    ]);
  },
  goForUpiPushTransaction: function (
    paymentFlow,
    bankAccountJson,
    vpaName,
    merchantDetailsJson,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "goForUpiPushTransaction", [
      paymentFlow,
      bankAccountJson,
      vpaName,
      merchantDetailsJson,
    ]);
  },
  fetchUpiBalance: function (bankAccountJson, vpaName, success, error) {
    exec(success, error, PLUGIN_NAME, "fetchUpiBalance", [
      bankAccountJson,
      vpaName,
    ]);
  },
  setUpiMpin: function (bankAccountJson, vpaName, success, error) {
    exec(success, error, PLUGIN_NAME, "setUpiMpin", [bankAccountJson, vpaName]);
  },
  getBin: function (
    cardSixDigit,
    tokenType,
    token,
    mid,
    referenceId,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "getBin", [
      cardSixDigit,
      tokenType,
      token,
      mid,
      referenceId,
    ]);
  },
  fetchNBList: function (
    tokenType,
    token,
    mid,
    orderId,
    referenceId,
    success,
    error
  ) {
    exec(success, error, PLUGIN_NAME, "fetchNBList", [
      tokenType,
      token,
      mid,
      orderId,
      referenceId,
    ]);
  },
  fetchEmiDetails: function (channelCode, cardType, success, error) {
    exec(success, error, PLUGIN_NAME, "fetchEmiDetails", [
      channelCode,
      cardType,
    ]);
  },
  getLastNBSavedBank: function (success, error) {
    exec(success, error, PLUGIN_NAME, "getLastNBSavedBank", []);
  },
  getLastSavedVPA: function (success, error) {
    exec(success, error, PLUGIN_NAME, "getLastSavedVPA", []);
  },
  isAuthCodeValid: function (clientId, authCode, success, error) {
    exec(success, error, PLUGIN_NAME, "isAuthCodeValid", [clientId, authCode]);
  },
  getEnvironment: function (success, error) {
    exec(success, error, PLUGIN_NAME, "getEnvironment", []);
  },
  setEnvironment: function (environment, success, error) {
    exec(success, error, PLUGIN_NAME, "setEnvironment", [environment]);
  },
};

module.exports = CustomUISDK;
