package com.capacitor.aws.amplify;

import android.util.Log;

public class AwsAmplify {

    public String echo(String value) {
        Log.i("Echo", value);
        return value;
    }
}
