package com.capacitor.aws.amplify;

import androidx.annotation.NonNull;
import androidx.annotation.Nullable;

import com.getcapacitor.JSObject;
import com.google.gson.Gson;

import org.json.JSONException;

public class AwsAuthSession {
  @NonNull
  private final String identityId;

  @NonNull
  private final String accessToken;

  @NonNull
  private final String idToken;

  @NonNull
  private final String refreshToken;

  @Nullable
  private final String deviceKey;

  /**
   * Constructs a new builder of {@link AwsAuthSession}.
   */
  @NonNull
  public static Builder builder(@NonNull String id) {
    return new Builder(id);
  }

  AwsAuthSession(@NonNull Builder builder) {
    identityId = builder.mIdentityId;
    accessToken = builder.mAccessToken;
    idToken = builder.mIdToken;
    refreshToken = builder.mRefreshToken;
    deviceKey = builder.mDeviceKey;
  }

  @NonNull
  public String getIdentityId() {
    return identityId;
  }

  @NonNull
  public String getAccessToken() {
    return accessToken;
  }

  @NonNull
  public String getIdToken() {
    return idToken;
  }

  @NonNull
  public String getRefreshToken() {
    return refreshToken;
  }

  @Nullable
  public String getDeviceKey() {
    return deviceKey;
  }

  @Nullable
  public JSObject toJson() {
    try {
      String jsonInString = new Gson().toJson(this);
      return new JSObject(jsonInString);
    } catch (JSONException e) {
      return null;
    }
  }

  /**
   * Builder for creating an {@link AwsAuthSession}.
   */
  public static final class Builder {
    String mIdentityId;

    String mAccessToken;

    String mIdToken;

    String mRefreshToken;

    @Nullable
    String mDeviceKey;

    public Builder(@NonNull String identityId) {
      mIdentityId = identityId;
    }

    public Builder setAccessToken(String accessToken) {
      mAccessToken = accessToken;
      return this;
    }

    public Builder setIdToken(String idToken) {
      mIdToken = idToken;
      return this;
    }

    public Builder setRefreshToken(String refreshToken) {
      mRefreshToken = refreshToken;
      return this;
    }

    public Builder setDeviceKey(@Nullable String deviceKey) {
      mDeviceKey = deviceKey;
      return this;
    }

    /**
     * Constructs the {@link AwsAuthSession} defined by this builder.
     */
    @NonNull
    public AwsAuthSession build() {
      return new AwsAuthSession(this);
    }
  }
}

