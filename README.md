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

Note : We are working on ionic-native wrapper for custom ui sdk  so that you can use below command to add wapper
 - npm install ionic-native/custom-uisdk

But for now use below process to add ionic wapper

Take checkout from below git command out from your cordova project directory
 - git clone -b 'customui-sdk' https://github.com/paytm/ionic-native.git
 - cd ionic-native
 - npm i
 - npm run build

The dist directory will contain a sub directory _@ionic-native_ with all the packages compiled in there. Copy the package(custom-uisdk) to your app's _node_modules_ under the _@ionic-native_ directory.
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
