export interface AwsAmplifyPlugin {
  load(options: { cognitoConfig: AWSCognitoConfig }): Promise<void>;
  signIn(options: {
    email: string;
    password: string;
  }): Promise<CognitoAuthSession>;
  federatedSignIn(options: {
    provider: string;
  }): Promise<CognitoAuthSession>;
  signOut(): Promise<any>;
}

export interface CognitoAuthSession {
  accessToken: string;
  idToken: string;
  identityId: string;
  refreshToken: string;
  deviceKey: string | null;
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
