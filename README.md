# Paytm Custom UI SDK ionic cordova

Paytm Custom UI SDK facilitates you to build your own Payment UI or Checkout page as per your requirements. You can easily integrate this non UI SDK in your App and call the methods to perform further transactions on the Paytm platform using the different available payment methods. The SDK provides multiple benefits to the merchants e.g. Enhanced success rates and reduced transaction time because of saved payment instruments and native experience

This Cordova plugin helps you to be able to use the Custom UI SDK with your ionic application. This plugin supports both Android and iOS.

## Installation:

Add the plugin in your ionic application with the following command.

`ionic cordova plugin add cordova-paytm-customuisdk`

It is also possible to install the plugin via repo url directly

`ionic cordova plugin add https://github.com/paytm/paytm-customuisdk-cordova.git`

## Pre-requisite

### ionic-native wrapper

1. Checkout ionic-native public repo from _https://github.com/ionic-team/ionic-native_

2. Add a wrapper for _CustomUiSDK_ in the ionic-native repo you created in the last step by adding the following command in ionic-native directory.

```
gulp plugin:create -n custom-uisdk
```

Running the command above will create a new directory src/@ionic-native/plugins/custom-uisdk/ with a single file in there: _index.ts_. This file is where all the plugin definitions should be.

3. Remove all the statements from the _index.ts_ file and add the following code in it.

````
import { Injectable } from '@angular/core';
import {
  Plugin,
  Cordova,
  CordovaProperty,
  CordovaInstance,
  InstanceProperty,
  IonicNativePlugin,
} from '@ionic-native/core';

/**
 * @name CustomUISDK
 * @description
 * This plugin is used to access Paytm's native CustomUISDK framework's apis.
 *
 * @usage
 * ```typescript
 * import { CustomUISDK } from '@ionic-native/custom-uisdk';
 *
 *
 * constructor(private customuisdk: CustomUISDK) { }
 *
 * ...
 *
 *
 * this.customuisdk.functionName('Hello', 123)
 *   .then((res: any) => console.log(res))
 *   .catch((error: any) => console.error(error));
 *
 * ```
 */
@Plugin({
  pluginName: 'cordova-paytm-customuisdk',
  plugin: 'cordova-paytm-customuisdk', // npm package name, example: cordova-plugin-camera
  pluginRef: 'paytm.customuisdk', // the variable reference to call the plugin, example: navigator.geolocation
  repo: '', // the github repository URL for the plugin
  install: '', // OPTIONAL install command, in case the plugin requires variables
  installVariables: [], // OPTIONAL the plugin requires variables
  platforms: ['Android, iOS'], // Array of platforms supported, example: ['Android', 'iOS']
})
@Injectable()
export class CustomUISDK extends IonicNativePlugin {
  /**
   * This function show dialog to ask user permision to fetch authcode
   * @param clientId {string} unique id give to each merchant
   * @param mid {string} merchant id
   * @return {Promise<string>} Returns authcode
   */
  @Cordova()
  fetchAuthCode(clientId: string, mid: string): Promise<string> {
    return;
  }

  /**
   * This function check that paytm app is installed or not
   * @return {Promise<boolean>} Returns installed - true or not -false
   */
  @Cordova()
  isPaytmAppInstalled(): Promise<boolean> {
    return;
  }

  /**
   * @param mid {string} merchant id
   * @return {Promise<boolean>} Returns if has payment methods - true or not -false
   */
  @Cordova()
  checkHasInstrument(mid: string): Promise<boolean> {
    return;
  }

  /**
   * @param mid {string} merchant id
   * @param orderId {string} order id
   * @param txnToken {string} transaction token
   * @param amount {string} transaction amount
   * @param isStaging {boolean} staging or production
   * @param callbackUrl {string} callback url only required for custom url page
   */
  @Cordova()
  initPaytmSDK(
    mid: string,
    orderId: string,
    txnToken: string,
    amount: string,
    isStaging: boolean,
    callbackUrl: string
  ) {
    return;
  }

  /**
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForWalletTransaction(paymentFlow: string): Promise<any> {
    return;
  }

  /**
   * @param cardNumber {string} card number
   * @param cardExpiry {string} card expiry
   * @param cardCvv {string} card cvv
   * @param cardType {string} card type debit or credit
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @param channelCode {string} bank channel code
   * @param issuingBankCode {string} issuing bank code
   * @param emiChannelId {string} emi plan id
   * @param authMode {string} authentication mode 'otp' 'pin'
   * @param saveCard {boolean} save card for next time
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForNewCardTransaction(
    cardNumber: string,
    cardExpiry: string,
    cardCvv: string,
    cardType: string,
    paymentFlow: string,
    channelCode: string,
    issuingBankCode: string,
    emiChannelId: string,
    authMode: string,
    saveCard: boolean
  ): Promise<any> {
    return;
  }

  /**
   * @param cardId {string} card id of saved card
   * @param cardCvv {string} card cvv
   * @param cardType {string} card type  debit or credit
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @param channelCode {string} bank channel code
   * @param issuingBankCode {string} issuing bank code
   * @param emiChannelId {string} emi plan id
   * @param authMode {string} authentication mode 'otp' 'pin'
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForSavedCardTransaction(
    cardId: string,
    cardCvv: string,
    cardType: string,
    paymentFlow: string,
    channelCode: string,
    issuingBankCode: string,
    emiChannelId: string,
    authMode: string
  ): Promise<any> {
    return;
  }

  /**
   * @param netBankingCode {string} bank channel code
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForNetBankingTransaction(netBankingCode: string, paymentFlow: string): Promise<any> {
    return;
  }

  /**
   * @param upiCode {string} upi code
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @param saveVPA {boolean} save vpa for future transaction
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForUpiCollectTransaction(upiCode: string, paymentFlow: string, saveVPA: boolean): Promise<any> {
    return;
  }

  /**
   * @return {Promise<any>} Returns upi app list names
   */
  @Cordova()
  getUpiIntentList(): Promise<any> {
    return;
  }

  /**
   * @param appName {string} upi app name
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForUpiIntentTransaction(appName: string, paymentFlow: string): Promise<any> {
    return;
  }

  /**
   * @param vpaName {string} vpa name
   * @param paymentFlow {string} payment type NONE, ADDANDPAY
   * @param bankAccountJson {{}} bank account json object
   * @param merchantDetailsJson {{}} merchant detail json
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  goForUpiPushTransaction(
    paymentFlow: string,
    bankAccountJson: {},
    vpaName: string,
    merchantDetailsJson: {}
  ): Promise<any> {
    return;
  }

  /**
   * @param vpaName {string} vpa name
   * @param bankAccountJson {{}} bank account json object
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  fetchUpiBalance(bankAccountJson: {}, vpaName: string): Promise<any> {
    return;
  }

  /**
   * @param vpaName {string} vpa name
   * @param bankAccountJson {{}} bank account json object
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  setUpiMpin(bankAccountJson: {}, vpaName: string): Promise<any> {
    return;
  }

  /**
   * @param cardSixDigit {string} card starting six digit
   * @param tokenType {string} token type ACCESS or TXN_TOKEN
   * @param token {string} token fetch from api
   * @param mid {string} merchant id
   * @param referenceId {string} reference id
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  getBin(cardSixDigit: string, tokenType: string, token: string, mid: string, referenceId: string): Promise<any> {
    return;
  }

  /**
   * @param tokenType {string} token type ACCESS or TXN_TOKEN
   * @param token {string} token fetch from api
   * @param mid {string} merchant id
   * @param orderId {string} order id required only if token type is TXN_TOKEN
   * @param referenceId {string} reference id required only if token type is ACCESS
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  fetchNBList(tokenType: string, token: string, mid: string, orderId: string, referenceId: string): Promise<any> {
    return;
  }

  /**
   * @param channelCode {string} bank channel code
   * @param cardType {string} card type debit or credit
   * @return {Promise<any>} Returns object of response
   */
  @Cordova()
  fetchEmiDetails(channelCode: string, cardType: string): Promise<any> {
    return;
  }

  /**
   * @return {Promise<any>} Returns last successfully used net backing code
   */

  @Cordova()
  getLastNBSavedBank(): Promise<any> {
    return;
  }

  /**
   * @return {Promise<any>} Returns last successfully used vpa code
   */

  @Cordova()
  getLastSavedVPA(): Promise<any> {
    return;
  }

  /**
   * @param clientId {string} unique id give to each merchant
   * @param authCode {string} fetched auth code
   * @return {Promise<any>} Returns last successfully used vpa code
   */
  @Cordova()
  isAuthCodeValid(clientId: string, authCode: string): Promise<any> {
    return;
  }

  /**
   * @return {Promise<any>} Returns current environment
   */
  @Cordova()
  getEnvironment(): Promise<string> {
    return;
  }

  /**
   * @param environment {string} setting environment PRODUCTION or STAGING
   */
  @Cordova()
  setEnvironment(environment: string): void {
    return;
  }
}
````

4. Run the command `npm run build` in your _ionic-native_ directory, this will create a _dist_ directory. The dist directory will contain a sub directory _@ionic-native_ with all the packages compiled in there. Copy the package(custom-uisdk) you created to your app's _node_modules_ under the _@ionic-native_ directory.
   For example: `cp -r ../ionic-native/dist/@ionic-native/plugins/custom-uisdk node_modules/@ionic-native`. Change the path of directories as per your project structure.

## Usage:

Add the plugin to your app's provider list

```
import { CustomUISDK } from "@ionic-native/custom-uisdk/ngx";

@NgModule({
  declarations: [...],
  entryComponents: [...],
  imports: [...],
  providers: [..., CustomUISDK],
  bootstrap: [...]
})
export class AppModule {}
```

In your page from where you want to invoke the Custom UI SDK, add the following code:

```
import { CustomUISDK } from "@ionic-native/custom-uisdk/ngx";

 constructor(
    private customUI: CustomUISDK) {}
    // Call methods as per requirement
this.customUI
      .fetchAuthCode(this.clientId, this.mid)
      .then((res: any) => {
        this.authCode = res.response;
        alert(JSON.stringify(res));
      })
      .catch((err) => {
        this.value = err;
        alert(JSON.stringify(err));
      });
```

## Custom UI SDK API & SDK reference

**https://developer.paytm.com/docs/custom-ui-sdk/**
