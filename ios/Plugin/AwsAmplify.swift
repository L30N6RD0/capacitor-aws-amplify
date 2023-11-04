import Foundation
import Capacitor
import Amplify
import AmplifyPlugins
import AWSPluginsCore
import AWSMobileClient

@objc public class AwsAmplify: NSObject {
    private let TAG = "[Capacitor AwsAmplify]"
//    static public let instance = AwsAmplify()
    
//    private let sessionSubject = BehaviorSubject<Optional<AuthSession>>(value: nil)
//    public var isLoggedIn$: Observable<Bool> {
//        sessionSubject.map { session in
//            session != nil
//        }
//    }

    struct AccessTokenPayload: Decodable {
        var device_key:String
    }
    
    override public init() {
        super.init()
    }
    
    public func load(cognitoConfig: JSObject,
                onSuccess: @escaping () -> (),
                onError: @escaping (any Error) -> ()) {
        initAwsService(cognitoConfig: cognitoConfig, onSuccess: onSuccess, onError: onError)
    }
    
    func signIn(email: String,
                password: String,
                onSuccess: @escaping (AuthSignInResult) -> (),
                onError: @escaping (any Error) -> ()) {
        Amplify.Auth.signIn(username: email, password: password) { result in
            do {
                let signinResult: AuthSignInResult = try result.get()
                print ("\(self.TAG) SignIn: " + (signinResult.isSignedIn ? "Sign in succeeded" : "Sign in not complete"))
                onSuccess(signinResult)
            } catch {
                print ("\(self.TAG) Sign in failed \(error)")
                onError(error)
            }
        }
    }
    
    public func federatedSignIn(
        provider: String,
        onSuccess: @escaping (AuthSignInResult) -> (),
        onError: @escaping (any Error) -> ()
    ) {
        var authProvider: AuthProvider
        
        switch provider {
        case "Google":
            authProvider = AuthProvider.google
            break
        case "Facebook":
            authProvider = AuthProvider.facebook
            break
        case "SignInWithApple":
            authProvider = AuthProvider.apple
            break
        default:
            authProvider = AuthProvider.google
        }
        
        print ("\(self.TAG) federatedSignIn \(authProvider)")
        
        DispatchQueue.main.async {
            Amplify.Auth.signInWithWebUI(for: authProvider,
                                        presentationAnchor: UIApplication.shared.windows.first!, options: .preferPrivateSession()) { result in
                switch result {
                case .success(let result):
                    print("\(self.TAG) federatedSignIn effettuato con successo: \(result)")
                    onSuccess(result)
                case .failure(let error):
                    print("\(self.TAG) Impossibile effettuare il federatedSignIn: \(error)")
                    onError(error)
                }
            }
        }
    
    }
    
    public func signOut(
        onSuccess: @escaping (Bool) -> (),
        onError: @escaping (any Error) -> ()
    ) {
        Amplify.Auth.signOut() { result in
            switch result {
                case .success:
                    onSuccess(true)
                case .failure(let authError):
                    print("\(self.TAG) Sign out failed with error \(authError)")
                    onError(authError)
                }
        }
    }
    
    public func fetchAuthSession(
        onSuccess: @escaping (JSObject) -> (),
        onError: @escaping (any Error) -> ()
    ) {
        Amplify.Auth.fetchAuthSession { result in
            do {
                let session = try result.get()
                var ret: JSObject = [:]

                // Get user sub or identity id
                if let identityProvider = session as? AuthCognitoIdentityProvider {
                    let usersub = try identityProvider.getUserSub().get()
                    let identityId = try identityProvider.getIdentityId().get()
                    // print("User sub - \(usersub) and identity id \(identityId)")
                    
                    ret["identityId"] = identityId
                }

                // Get AWS credentials
                // if let awsCredentialsProvider = session as? AuthAWSCredentialsProvider {
                //     let credentials = try awsCredentialsProvider.getAWSCredentials().get()
                //     print("Access key - \(credentials.accessKey) ")
                // }

                // Get cognito user pool token
                if let cognitoTokenProvider = session as? AuthCognitoTokensProvider {
                    let tokens = try cognitoTokenProvider.getCognitoTokens().get()
                    // print("Id token - \(tokens.idToken) ")
                    
                    ret["accessToken"] = tokens.accessToken
                    ret["idToken"] = tokens.idToken
                    ret["refreshToken"] = tokens.refreshToken
                    
//                    Amplify.Auth.fetchDevices { result in
//                      switch result {
//                      case .success(let devices):
//                        print("\(self.TAG) devices", devices)
//                        print("\(self.TAG) device IDs", devices.map(\.id))
//                      case .failure(let error):
//                        print("\(self.TAG) error", error)
//                      }
//                    }
                    
                    // Retrieve the device key from the payload of access token
                    let accessToken = tokens.accessToken as NSString
//                    print("\(self.TAG) accessToken - \(tokens.idToken) ")
                    let chunks = accessToken.components(separatedBy: ".")
                    let accessTokenPayload = self.decodeJWTPart(part: chunks[1])
                    let deviceKey = accessTokenPayload?.device_key

                    ret["deviceKey"] = deviceKey
                }
                
//                self.sessionSubject.onNext(session)
                
                print("\(self.TAG) - Fetch Auth Session successfully")
//                print("\(self.TAG) - \(ret)")
                onSuccess(ret)
            } catch {
                print("\(self.TAG) Fetch auth session failed with error - \(error)")
                onError(error)
            }
        }
    }
    
    public func getCurrentUser() -> AuthUser {
        return Amplify.Auth.getCurrentUser()!
    }
    
    func base64StringWithPadding(encodedString: String) -> String {
        var stringTobeEncoded = encodedString.replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        let paddingCount = encodedString.count % 4
        for _ in 0..<paddingCount {
            stringTobeEncoded += "="
        }
        return stringTobeEncoded
    }

    func decodeJWTPart(part: String) -> AccessTokenPayload? {
        let payloadPaddingString = base64StringWithPadding(encodedString: part)
        guard let payloadData = Data(base64Encoded: payloadPaddingString) else {
            fatalError("payload could not converted to data")
        }
        return try? JSONDecoder().decode(AccessTokenPayload.self, from: payloadData)
    }
    
    private func initAwsService(cognitoConfig: JSObject,
                                onSuccess: @escaping () -> (),
                                onError: @escaping (any Error) -> ()) {
        let poolId = cognitoConfig["aws_cognito_identity_pool_id"] as! String
        let region = cognitoConfig["aws_cognito_region"] as! String
        let userPoolId = cognitoConfig["aws_user_pools_id"] as! String
        let clientId = cognitoConfig["aws_user_pools_web_client_id"] as! String
        
        let oauth = cognitoConfig["oauth"] as! JSObject
        let domain = oauth["domain"] as! String
        let redirectSignIn = oauth["redirectSignIn"] as! String
        let redirectSignOut = oauth["redirectSignOut"] as! String
        let scope = oauth["scope"] as! JSArray
        
        let scopeConv = scope.map { value in
            JSONValue.string(value as! String)
        } as! [JSONValue]
        
        let auth: AuthCategoryConfiguration = AuthCategoryConfiguration.init(plugins: [
            "awsCognitoAuthPlugin" : JSONValue.object([
                "CredentialsProvider" : JSONValue.object([
                    "CognitoIdentity" : JSONValue.object([
                        "Default" : JSONValue.object([
                            "PoolId" : JSONValue.string(poolId),
                            "Region" : JSONValue.string(region),
                        ])
                    ])
                ]),
                "CognitoUserPool" : JSONValue.object([
                    "Default" : JSONValue.object([
                        "PoolId" : JSONValue.string(userPoolId),
                        "AppClientId" : JSONValue.string(clientId),
                        "Region" : JSONValue.string(region),
                    ])
                ]),
                "Auth" : JSONValue.object([
                    "Default" : JSONValue.object([
                        "authenticationFlowType" : JSONValue.string("USER_SRP_AUTH"),
                        "OAuth" : JSONValue.object([
                            "WebDomain" : JSONValue.string(domain),
                            "AppClientId" : JSONValue.string(clientId),
                            "SignInRedirectURI" : JSONValue.string(redirectSignIn),
                            "SignOutRedirectURI" : JSONValue.string(redirectSignOut),
                            "Scopes" : JSONValue.array(scopeConv)
                        ]),
                    ])
                ]),
            ])
        ])
        
        let ampConfig: AmplifyConfiguration = AmplifyConfiguration.init(auth:auth)
        do {
            try Amplify.add(plugin: AWSCognitoAuthPlugin())
            try Amplify.configure(ampConfig)
            print("\(self.TAG) Amplify configured with auth plugin")
            
            Amplify.Hub.listen(to: .auth) { payload in
                
                switch payload.eventName {
                    case HubPayload.EventName.Auth.signedIn:
                    print("\(self.TAG) User signed in")
                    // Update UI
                    break
                    
                    case HubPayload.EventName.Auth.sessionExpired:
                    print("\(self.TAG) Session expired")
                        // Re-authenticate the user
                    break

                    case HubPayload.EventName.Auth.signedOut:
//                    self.sessionSubject.onNext(nil)
                    print("\(self.TAG) User signed out")
                        // Update UI
                    break

                    case HubPayload.EventName.Auth.userDeleted:
                    print("\(self.TAG) User deleted")
                        // Update UI
                    break
                    
                    case HubPayload.EventName.Auth.socialWebUISignInAPI:
                    print("\(self.TAG) Social login")
//                    self.fetchAuthSession { _ in } onError: { _ in }

                    break

                    default:
                        break
                }
                
//                print("\(self.TAG) Amplify.Hub.listen \(payload)")
            }
            onSuccess()
        } catch {
            print("\(self.TAG) An error occurred setting up Amplify: \(error)")
            onError(error)
        }
    }
    
//    public func getSession() -> Optional<AuthSession> {
//         do {
//             return try self.sessionSubject.value()
//         } catch {
//             return nil
//         }
//     }

    // public func hasFullRegistration() -> Observable<Bool> {
    //     return Observable.create { observer in
    //         AWSMobileClient.default().getUserAttributes { (userAttributes, error) in
    //             if error != nil {
    //                 print("\(self.TAG) User attributes error: \(error)")
    //                 observer.onNext(false)
    //             } else if let userAttributes = userAttributes {
    //                 print("\(self.TAG) User attributes: \(userAttributes)")
    //                 let registrationFull = userAttributes["custom:registration_full"]
    //                 if registrationFull != nil {
    //                     observer.onNext(true)
    //                 } else {
    //                     observer.onNext(false)
    //                 }
    //             }
    //         }
    //         return Disposables.create()
    //     }
    // }
}
