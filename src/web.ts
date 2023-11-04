import type { FederatedSignInOptions } from '@aws-amplify/auth/lib/types';
import { WebPlugin } from '@capacitor/core';
import type { CognitoUser } from 'amazon-cognito-identity-js';
import { Amplify, Auth } from 'aws-amplify';

import type {
  AWSCognitoConfig,
  AwsAmplifyPlugin,
  CognitoAuthSession,
} from './definitions';

export class AwsAmplifyWeb extends WebPlugin implements AwsAmplifyPlugin {
  private cognitoConfig?: AWSCognitoConfig;

  async load(options: { cognitoConfig: AWSCognitoConfig }): Promise<void> {
    this.cognitoConfig = options.cognitoConfig;
    Amplify.configure({ ...options.cognitoConfig });
  }
  async signIn(options: {
    email: string;
    password: string;
  }): Promise<CognitoAuthSession> {
    // console.log(LOG_PREFIX, options);
    if (!this.cognitoConfig) {
      throw new Error('call load first');
    }
    return new Promise((resolve, reject) => {
      Auth.signIn(options.email, options.password).then((user: CognitoUser) => {
        const cognitoAuthSession = this.getCognitoAuthSession(
          user,
          // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
          this.cognitoConfig!.aws_cognito_identity_pool_id,
        );
        cognitoAuthSession ? resolve(cognitoAuthSession) : reject();
      });
    });
  }

  async federatedSignIn(options: {
    provider: string;
  }): Promise<CognitoAuthSession> {
    // console.log(LOG_PREFIX, options);
    if (!this.cognitoConfig) {
      throw new Error('call load first');
    }
    return new Promise((resolve, reject) => {
      Auth.federatedSignIn(options as FederatedSignInOptions)
        .then(_ => {
          // console.log(LOG_PREFIX + " credential", cred);
          Auth.currentAuthenticatedUser().then(user => {
            // console.log(LOG_PREFIX + " user", user);
            const cognitoAuthSession = this.getCognitoAuthSession(
              user,
              // eslint-disable-next-line @typescript-eslint/no-non-null-assertion
              this.cognitoConfig!.aws_cognito_identity_pool_id,
            );
            cognitoAuthSession ? resolve(cognitoAuthSession) : reject();
          });
        })
        .catch(err => reject(err));
    });
  }

  async signOut(): Promise<any> {
    return Auth.signOut();
  }

  private getCognitoAuthSession(user: CognitoUser, identityId: string) {
    const userSession = user.getSignInUserSession();

    if (userSession) {
      const res: CognitoAuthSession = {
        accessToken: userSession.getAccessToken().getJwtToken(),
        idToken: userSession.getIdToken().getJwtToken(),
        identityId: identityId,
        refreshToken: userSession.getRefreshToken().getToken(),
        deviceKey: userSession.getAccessToken().decodePayload().device_key,
      };
      return res;
    }

    return null;
  }
}
