# @falconeta/capacitor-aws-amplify

plugin that handle amplify features

## Install

```bash
npm install @falconeta/capacitor-aws-amplify
npx cap sync
```

## API

<docgen-index>

* [`load(...)`](#load)
* [`signIn(...)`](#signin)
* [`federatedSignIn(...)`](#federatedsignin)
* [`signOut()`](#signout)
* [Interfaces](#interfaces)

</docgen-index>

<docgen-api>
<!--Update the source file JSDoc comments and rerun docgen to update the docs below-->

### load(...)

```typescript
load(options: { cognitoConfig: AWSCognitoConfig; }) => Promise<void>
```

| Param         | Type                                                                              |
| ------------- | --------------------------------------------------------------------------------- |
| **`options`** | <code>{ cognitoConfig: <a href="#awscognitoconfig">AWSCognitoConfig</a>; }</code> |

--------------------


### signIn(...)

```typescript
signIn(options: { email: string; password: string; }) => Promise<CognitoAuthSession>
```

| Param         | Type                                              |
| ------------- | ------------------------------------------------- |
| **`options`** | <code>{ email: string; password: string; }</code> |

**Returns:** <code>Promise&lt;<a href="#cognitoauthsession">CognitoAuthSession</a>&gt;</code>

--------------------


### federatedSignIn(...)

```typescript
federatedSignIn(options: { provider: string; }) => Promise<CognitoAuthSession>
```

| Param         | Type                               |
| ------------- | ---------------------------------- |
| **`options`** | <code>{ provider: string; }</code> |

**Returns:** <code>Promise&lt;<a href="#cognitoauthsession">CognitoAuthSession</a>&gt;</code>

--------------------


### signOut()

```typescript
signOut() => Promise<any>
```

**Returns:** <code>Promise&lt;any&gt;</code>

--------------------


### Interfaces


#### AWSCognitoConfig

| Prop                               | Type                                                                                                                     |
| ---------------------------------- | ------------------------------------------------------------------------------------------------------------------------ |
| **`aws_cognito_region`**           | <code>string</code>                                                                                                      |
| **`aws_user_pools_id`**            | <code>string</code>                                                                                                      |
| **`aws_user_pools_web_client_id`** | <code>string</code>                                                                                                      |
| **`aws_cognito_identity_pool_id`** | <code>string</code>                                                                                                      |
| **`aws_mandatory_sign_in`**        | <code>string</code>                                                                                                      |
| **`oauth`**                        | <code>{ domain: string; scope: string[]; redirectSignIn: string; redirectSignOut: string; responseType: 'code'; }</code> |


#### CognitoAuthSession

| Prop               | Type                        |
| ------------------ | --------------------------- |
| **`accessToken`**  | <code>string</code>         |
| **`idToken`**      | <code>string</code>         |
| **`identityId`**   | <code>string</code>         |
| **`refreshToken`** | <code>string</code>         |
| **`deviceKey`**    | <code>string \| null</code> |

</docgen-api>
