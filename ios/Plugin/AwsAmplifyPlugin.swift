import Foundation
import Amplify
import Capacitor

/**
 * Please read the Capacitor iOS Plugin Development Guide
 * here: https://capacitorjs.com/docs/plugins/ios
 */
@objc(AwsAmplifyPlugin)
public class AwsAmplifyPlugin: CAPPlugin {
    private let implementation = AwsAmplify()
    
    @objc func load(_ call: CAPPluginCall) {
        let cognitoConfig = call.getObject("cognitoConfig")!
        
        implementation.load(
            cognitoConfig: cognitoConfig,
            onSuccess: {
                call.resolve()
            },
            onError: {error in
                print(error)
                call.reject(error.localizedDescription)
            })
    }
    
    @objc func signIn(_ call: CAPPluginCall) {
        let email = call.getString("email") ?? ""
        let password = call.getString("password") ?? ""
        
        implementation.signIn(
            email: email,
            password: password,
            onSuccess: {data in
                self.implementation.fetchAuthSession(
                    onSuccess: {session in
                        call.resolve(session)
                    },
                    onError: {error in
                        call.reject(error.localizedDescription)
                    })
            },
            onError: {error in
                print(error)
                call.reject(error.localizedDescription)
            })
    }
    
    @objc func signOut(_ call: CAPPluginCall) {
        self.implementation.signOut(
            onSuccess: { response in
                call.resolve(response)
            }, onError: { error in
                call.reject(error.localizedDescription)
            })
    }
    
    @objc func federatedSignIn(_ call: CAPPluginCall) {
        let provider = call.getString("provider") ?? ""
        
        self.implementation.fetchAuthSession(
            onSuccess: {session in
                if(session["status"] as! Int == 0) {
                    call.resolve(session)
                } else {
                    self.implementation.federatedSignIn(
                        provider: provider,
                        onSuccess: { result in
                            if(result["status"] as! Int == 0) {
                                self.fetchAuthSession(call)
                            } else {
                                call.resolve(result)
                            }
                        },
                        onError: { error in
                            print(error)
                            call.reject(error.localizedDescription)
                        })
                }
                
            },
            onError: {error in
                call.reject(error.localizedDescription)
            })
        
        
    }
    @objc func fetchAuthSession(_ call: CAPPluginCall) {
        
        self.implementation.fetchAuthSession(
            onSuccess: {session in
                call.resolve(session)
            },
            onError: {error in
                call.reject(error.localizedDescription)
            })
    }
    
    @objc func getUserAttributes(_ call: CAPPluginCall) {
        
        self.implementation.getUserAttributes(
            onSuccess: {session in
                call.resolve(session)
            },
            onError: {error in
                call.reject(error.localizedDescription)
            })
    }
    
    @objc func updateUserAttributes(_ call: CAPPluginCall) {
        
        if let userAttributes = call.getArray("attributes") as JSArray?{
            self.implementation.updateUserAttributes(
                userAttributes: userAttributes.map {
                    let attribute = $0 as! JSObject
                    return AuthUserAttribute(getAttributeKey(key: attribute["name"] as! String), value: attribute["value"] as! String)
                },
                onSuccess: {session in
                    call.resolve(session)
                },
                onError: {error in
                    call.reject(error.localizedDescription)
                })
        }
        
    }
    
    @objc func deleteUser(_ call: CAPPluginCall) {
        implementation.deleteUser(
            onSuccess: {
                call.resolve(["status": 0])
            },
            onError: {error in
                call.resolve(["status": -1])
            })
    }
    
    private func getAttributeKey(key: String) -> AuthUserAttributeKey{
        switch(key){
        case "address":
            return AuthUserAttributeKey.address
        case "birthDate":
            return AuthUserAttributeKey.birthDate
        case "email":
            return AuthUserAttributeKey.email
        case "familyName":
            return AuthUserAttributeKey.familyName
        case "gender":
            return AuthUserAttributeKey.gender
        case "givenName":
            return AuthUserAttributeKey.givenName
        case "locale":
            return AuthUserAttributeKey.locale
        case "middleName":
            return AuthUserAttributeKey.middleName
        case "name":
            return AuthUserAttributeKey.name
        case "nickname":
            return AuthUserAttributeKey.nickname
        case "phoneNumber":
            return AuthUserAttributeKey.phoneNumber
        case "picture":
            return AuthUserAttributeKey.picture
        case "preferredUsername":
            return AuthUserAttributeKey.preferredUsername
        default:
            return AuthUserAttributeKey.custom(key)
        }
    }
    
    // var permissionCallID: String?
    // var locationManager: CLLocationManager?
    
    // @objc override public func requestPermissions(_ call: CAPPluginCall) {
    //     if let manager = locationManager, CLLocationManager.locationServicesEnabled() {
    //         if CLLocationManager.authorizationStatus() == .notDetermined {
    //             bridge?.saveCall(call)
    //             permissionCallID = call.callbackId
    //             manager.requestWhenInUseAuthorization()
    //         } else {
    //             checkPermissions(call)
    //         }
    //     } else {
    //         call.reject("Location services are disabled")
    //     }
    // }
}
