export interface AwsAmplifyPlugin {
  load(options: { cognitoConfig: AWSCognitoConfig }): Promise<void>;
  signIn(options: { email: string; password: string }): Promise<CognitoAuthSession>;
  signUp(options: { email: string; password: string }): Promise<CognitoAuthSession>;
  confirmSignUp(options: { username: string; challengeResponse: string }): Promise<CognitoAuthSession>;
  confirmSignIn(options: { username: string; challengeResponse: string }): Promise<CognitoAuthSession>;
  federatedSignIn(options: { provider: CognitoHostedUIIdentityProvider }): Promise<CognitoAuthSession>;
  fetchAuthSession(): Promise<CognitoAuthSession>;
  getUserAttributes(): Promise<{
    status: AwsAmplifyPluginResponseStatus;
    userAttributes: Record<string, string>;
  }>;
  updateUserAttributes(options: {
    attributes: {
      name: AuthUserAttributeKey | string;
      value: string;
    }[];
  }): Promise<{
    status: AwsAmplifyPluginResponseStatus;
    userAttributes: Record<string, string>;
  }>;
  signOut(): Promise<{
    status: AwsAmplifyPluginResponseStatus;
  }>;
  deleteUser(): Promise<{
    status: AwsAmplifyPluginResponseStatus;
  }>;
}
export interface CognitoAuthSession {
  accessToken?: string;
  idToken?: string;
  identityId?: string;
  refreshToken?: string;
  deviceKey?: string | null;
  status: AwsAmplifyPluginResponseStatus;
}
export interface AWSCognitoConfig {
  aws_cognito_region: string;
  aws_user_pools_id: string;
  aws_user_pools_web_client_id: string;
  aws_cognito_identity_pool_id: string;
  aws_mandatory_sign_in: string;
  oauth: {
    domain: string;
    scope: string[];
    redirectSignIn: string;
    redirectSignOut: string;
    responseType: 'code';
  };
}
export declare enum AwsAmplifyPluginResponseStatus {
  Ok = 0,
  Ko = -1,
  Cancelled = -2,
  SignedOut = -3,
}
export declare enum CognitoHostedUIIdentityProvider {
  Cognito = 'COGNITO',
  Google = 'Google',
  Facebook = 'Facebook',
  Amazon = 'LoginWithAmazon',
  Apple = 'SignInWithApple',
}
export declare enum AuthUserAttributeKey {
  address = 'address',
  birthDate = 'birthDate',
  email = 'email',
  familyName = 'familyName',
  gender = 'gender',
  givenName = 'givenName',
  locale = 'locale',
  middleName = 'middleName',
  name = 'name',
  nickname = 'nickname',
  phoneNumber = 'phoneNumber',
  picture = 'picture',
  preferredUsername = 'preferredUsername',
}
