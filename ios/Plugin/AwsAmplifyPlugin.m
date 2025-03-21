#import <Foundation/Foundation.h>
#import <Capacitor/Capacitor.h>

// Define the plugin using the CAP_PLUGIN Macro, and
// each method the plugin supports using the CAP_PLUGIN_METHOD macro.
CAP_PLUGIN(AwsAmplifyPlugin, "AwsAmplify",
           CAP_PLUGIN_METHOD(load, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(signIn, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(signOut, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(federatedSignIn, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(fetchAuthSession, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(getUserAttributes, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(updateUserAttributes, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(deleteUser, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(signUp, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(confirmSignUp, CAPPluginReturnPromise);
           CAP_PLUGIN_METHOD(confirmSignIn, CAPPluginReturnPromise);
)
