package com.capacitor.aws.amplify;

import android.os.Build;

import androidx.annotation.RequiresApi;

import com.getcapacitor.Plugin;
import com.getcapacitor.PluginCall;
import com.getcapacitor.PluginMethod;
import com.getcapacitor.annotation.CapacitorPlugin;

@CapacitorPlugin(name = "AwsAmplify")
public class AwsAmplifyPlugin extends Plugin {

    private final AwsAmplify implementation = new AwsAmplify();

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void load(PluginCall call) {
        var cognitoConfig = call.getObject("cognitoConfig");

        implementation.load(
                cognitoConfig,
                bridge.getContext(),
                result -> call.resolve(),
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void signOut(PluginCall call) {

        implementation.signOut(
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void federatedSignIn(PluginCall call) {
        String provider = call.getString("provider");

        implementation.federatedSignIn(
                provider,
                this.getActivity(),
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void fetchAuthSession(PluginCall call) {

        implementation.fetchAuthSession(
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void getUserAttributes(PluginCall call) {

        implementation.getUserAttributes(
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void updateUserAttributes(PluginCall call) {
        var userAttributes = call.getArray("attributes");
        implementation.updateUserAttributes(userAttributes,
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

    @RequiresApi(api = Build.VERSION_CODES.N)
    @PluginMethod
    public void deleteUser(PluginCall call) {

        implementation.deleteUser(
                call::resolve,
                error -> {
                    call.reject(error.toString());
                });
    }

}
