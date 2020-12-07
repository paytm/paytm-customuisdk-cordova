# Paytm Custom UI SDK ionic cordova

Paytm Custom UI SDK facilitates you to build your own Payment UI or Checkout page as per your requirements. You can easily integrate this non UI SDK in your App and call the methods to perform further transactions on the Paytm platform using the different available payment methods. The SDK provides multiple benefits to the merchants e.g. Enhanced success rates and reduced transaction time because of saved payment instruments and native experience

This Cordova plugin helps you to be able to use the Custom UI SDK with your ionic application. This plugin supports both Android and iOS.

## Installation:

Add the plugin in your ionic application with the following command.

`ionic cordova plugin add cordova-paytm-customuisdk`

It is also possible to install the plugin via repo url directly

`ionic cordova plugin add https://github.com/paytm/paytm-customuisdk-cordova.git`

### ionic-native wrapper

 - npm install ionic-native/custom-uisdk

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
        alert(JSON.stringify(err));
      });
```

## Custom UI SDK API & SDK reference

**https://developer.paytm.com/docs/custom-ui-sdk/**
