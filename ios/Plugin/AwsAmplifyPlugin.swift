import Foundation
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
            onSuccess: { success in
            call.resolve([
                "logout": success
            ])
        }, onError: { error in
            call.reject(error.localizedDescription)
        })
    }
    
    @objc func federatedSignIn(_ call: CAPPluginCall) {
        let provider = call.getString("provider") ?? ""
        
        self.implementation.federatedSignIn(
            provider: provider,
            onSuccess: { data in
                print("federatedSignIn onSuccess \(data)")
                self.implementation.fetchAuthSession(
                    onSuccess: {session in
                        call.resolve(session)
                    },
                    onError: {error in
                        call.reject(error.localizedDescription)
                    })
            },
            onError: { error in
                print(error)
                call.reject(error.localizedDescription)
            })
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
