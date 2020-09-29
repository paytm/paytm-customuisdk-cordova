/**
 */
package com.paytm;

import android.app.Application;
import android.util.Log;
import net.one97.paytm.nativesdk.PaytmSDK;

public class MyApplication extends Application {
    @Override
    public void onCreate() {
        Log.d("MyApplication", "onCreate");
        super.onCreate();
        PaytmSDK.init(this);
    }
}