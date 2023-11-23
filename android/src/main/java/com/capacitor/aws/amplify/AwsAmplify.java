package com.capacitor.aws.amplify;

import android.app.Activity;
import android.content.Context;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;
import androidx.annotation.RequiresApi;

import com.amazonaws.mobile.client.AWSMobileClient;
import com.amazonaws.mobile.client.DeviceOperations;
import com.amazonaws.mobile.client.results.Device;
import com.amazonaws.mobile.client.results.ListDevicesResult;
import com.amazonaws.mobile.client.results.Tokens;
import com.amplifyframework.AmplifyException;
import com.amplifyframework.auth.AuthCategoryConfiguration;
import com.amplifyframework.auth.AuthException;
import com.amplifyframework.auth.AuthProvider;
import com.amplifyframework.auth.cognito.AWSCognitoAuthPlugin;
import com.amplifyframework.auth.cognito.AWSCognitoAuthSession;
import com.amplifyframework.auth.result.AuthSessionResult;
import com.amplifyframework.auth.result.AuthSignInResult;
import com.amplifyframework.core.Amplify;
import com.amplifyframework.core.AmplifyConfiguration;
import com.amplifyframework.core.category.CategoryConfiguration;
import com.getcapacitor.JSObject;

import org.json.JSONException;
import org.json.JSONObject;

import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Objects;
import java.util.function.Consumer;

public class AwsAmplify {

  @RequiresApi(api = Build.VERSION_CODES.N)
  public void load(JSObject cognitoConfig, Context context, @NonNull Consumer onSuccess, @NonNull Consumer<Exception> onError) {

    JSObject oauth = (JSObject) cognitoConfig.getJSObject("oauth");

    try {
      JSONObject auth = new JSONObject();
      auth.put("plugins", new JSONObject().put(
          "awsCognitoAuthPlugin", new JSONObject().put(
            "IdentityManager", new JSONObject().put(
              "Default", new JSONObject())
          ).put(
            "CredentialsProvider", new JSONObject().put(
              "CognitoIdentity", new JSONObject().put(
                "Default", new JSONObject().put(
                  "PoolId", cognitoConfig.get("aws_cognito_identity_pool_id")
                ).put(
                  "Region", cognitoConfig.get("aws_cognito_region")
                )
              )
            )
          ).put(
            "CognitoUserPool", new JSONObject().put(
              "Default", new JSONObject().put(
                "PoolId", cognitoConfig.get("aws_user_pools_id")
              ).put(
                "AppClientId", cognitoConfig.get("aws_user_pools_web_client_id")
              ).put(
                "Region", cognitoConfig.get("aws_cognito_region")
              )
            )
          ).put(
            "Auth", new JSONObject().put(
              "Default", new JSONObject().put(
                "authenticationFlowType", "USER_SRP_AUTH"
              ).put(
                "OAuth", new JSONObject().put(
                  "WebDomain", oauth.get("domain")
                ).put(
                  "AppClientId", cognitoConfig.get("aws_user_pools_web_client_id")
                ).put(
                  "SignInRedirectURI", oauth.get("redirectSignIn")
                ).put(
                  "SignOutRedirectURI", oauth.get("redirectSignOut")
                ).put(
                  "Scopes", oauth.getJSONArray("scope")
                )
              )
            )
          )
        )
      );

      Amplify.addPlugin(new AWSCognitoAuthPlugin());
      AuthCategoryConfiguration authConfig = new AuthCategoryConfiguration();
      authConfig.populateFromJSON(auth);
      Map<String, CategoryConfiguration> config = new HashMap();
      config.put("auth", authConfig);
      AmplifyConfiguration configuration = new AmplifyConfiguration(config);
      Amplify.configure(configuration, context);
      onSuccess.accept(null);
    } catch (AmplifyException e) {
      onError.accept(e);
    } catch (JSONException e) {
      onError.accept(e);
      throw new RuntimeException(e);
    }

  }


  @RequiresApi(api = Build.VERSION_CODES.N)
  public void federatedSignIn(String providerString, Activity activity, @NonNull Consumer<JSObject> onSuccess,
                              @NonNull Consumer<Exception> onError) {
    AuthProvider provider = AuthProvider.google();

    if (providerString.equals("facebook")) {
      provider = AuthProvider.facebook();
    }

    if (providerString.equals("SignInWithApple")) {
      provider = AuthProvider.apple();
    }

    AuthProvider finalProvider = provider;
    fetchAuthSession(response -> {
      var status = -1;

      try {
        status = response.getInt("status");
      } catch (JSONException e) {
        onError.accept(e);
        return;
      }

      if (status == 0) {
        onSuccess.accept(response);
      } else {
        Amplify.Auth.signInWithSocialWebUI(
          finalProvider,
          activity,
          result -> {
            fetchAuthSession(
              onSuccess,
              onError);
          },
          error -> {
            onError.accept(error);
          });
      }
    }, error -> {
      onError.accept(error);
    });


  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  public void fetchAuthSession(@Nullable Consumer<JSObject> onSuccess,
                               @Nullable Consumer<Exception> onError) {
    fetchSessionInternal(
      authSession -> {

        if (authSession != null && onSuccess != null) {
          JSObject ret = new JSObject();
          ret.put("status", 0);
          ret.put("accessToken", authSession.getAccessToken());
          ret.put("idToken", authSession.getIdToken());
          ret.put("identityId", authSession.getIdentityId());
          ret.put("refreshToken", authSession.getRefreshToken());
          ret.put("deviceKey", authSession.getDeviceKey());
          onSuccess.accept(ret);
        }
      },
      error -> {
        if (onError != null) {
          String message = error.getMessage();
          String suggestion = error.getRecoverySuggestion();
          Throwable cause = error.getCause();
          JSObject ret = new JSObject();
          ret.put("status", -1);
          if (AuthException.SignedOutException.class.isInstance(error)) {
            ret.put("status", -3);
          }
          onSuccess.accept(ret);
        }
      });
  }

  @RequiresApi(api = Build.VERSION_CODES.N)
  private void fetchSessionInternal(@Nullable Consumer<AwsAuthSession> onSuccess,
                                    @Nullable Consumer<AuthException> onError) {
    Amplify.Auth.fetchAuthSession(
      session -> {
        AWSCognitoAuthSession cognitoAuthSession = (AWSCognitoAuthSession) session;
        AuthSessionResult<String> authSessionResult = cognitoAuthSession.getIdentityId();
        AuthSessionResult.Type type = authSessionResult.getType();
        String identityId = authSessionResult.getValue();

        // Success.
        if (type == AuthSessionResult.Type.SUCCESS && identityId != null) {
//          Log.i(TAG, "IdentityId: " + identityId);

          try {
            AwsAuthSession authSession = getSessionInternal();
//            setSession(authSession);

            if (authSession != null && onSuccess != null) {
              onSuccess.accept(authSession);
            }

          } catch (Exception e) {
            e.printStackTrace();

            if (onError != null) {
              onError.accept(new AuthException("Error", e.toString()));
            }
          }
        }

        // Error.
        else {
          AuthException error = cognitoAuthSession.getIdentityId().getError();
//          Log.e(TAG, "IdentityId not present because: " + error);

          if (onError != null) {
            onError.accept(error);
          }
        }
      },
      error -> {
//        Log.e(TAG, "Session error: ", error);

        if (onError != null) {
          onError.accept(error);
        }
      });
  }

  private AwsAuthSession getSessionInternal() {
    try {
      AWSMobileClient mClient = AWSMobileClient.getInstance();
      Tokens tokens = mClient.getTokens();

      String accessToken = tokens.getAccessToken().getTokenString();
      String idToken = tokens.getIdToken().getTokenString();
      String refreshToken = tokens.getRefreshToken().getTokenString();

//      DeviceOperations deviceOperations = mClient.getDeviceOperations();
//      ListDevicesResult devicesList = deviceOperations.list();
//      List<Device> devices = devicesList.getDevices();

      String deviceKey = null;

//      if (!devices.isEmpty()) {
//        deviceKey = deviceOperations.get().getDeviceKey();
//      }

      return AwsAuthSession.builder(mClient.getIdentityId())
        .setAccessToken(accessToken)
        .setIdToken(idToken)
        .setRefreshToken(refreshToken)
        .setDeviceKey(deviceKey)
        .build();
    } catch (Exception e) {
      return null;
    }
  }

  /**
   * Sign out of the current device.
   *
   * @param onSuccess success callback.
   * @param onError   error callback.
   */
  @RequiresApi(api = Build.VERSION_CODES.N)
  public void signOut(@NonNull Consumer<JSObject> onSuccess,
                      @NonNull Consumer<AuthException> onError) {
    JSObject ret = new JSObject();

    Amplify.Auth.signOut(
      () -> {
        ret.put("status", 0);
        onSuccess.accept(ret);
      },
      error -> {
        ret.put("status", -1);
        onSuccess.accept(ret);
      }
    );
  }
}
