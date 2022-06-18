//
//  AppCheck.swift
//  PizzeriaLosArcos
//
//  Created by Edgar López Enríquez on 18/06/22.
//

import Firebase

class MyAppCheckProviderFactory: NSObject, AppCheckProviderFactory {
  func createProvider(with app: FirebaseApp) -> AppCheckProvider? {
      #if targetEnvironment(simulator)
      // App Attest is not available on simulators.
      // Use a debug provider.
      let provider = AppCheckDebugProvider(app: app)

      // Print only locally generated token to avoid a valid token leak on CI.
      print("Firebase App Check debug token: \(provider?.localDebugToken() ?? "" )")

      return provider
      #else
      if #available(iOS 14.0, *) {
        // Use App Attest provider on real devices.
        return AppAttestProvider(app: app)
      } else {
        return DeviceCheckProvider(app: app)
      }
      #endif
  }
}
