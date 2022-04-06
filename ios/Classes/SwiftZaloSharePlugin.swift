import Flutter
import UIKit
import ZaloSDK
import CommonCrypto
import CryptoKit
import Foundation


public class Zalo {
    public static func application(
            _ application: UIApplication,
            open url: URL,
            sourceApplication: String?,
            annotation: Any
        ) -> Bool {
            return ZDKApplicationDelegate.sharedInstance().application(application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation
            )
        }

    @available(iOS 9.0, *)
    public static func application(
        _ app: UIApplication,
        open url: URL?,
        options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        return ZDKApplicationDelegate
            .sharedInstance()
            .application(app,
                            open: url as URL?,
                            sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?,
                            annotation: options[UIApplication.OpenURLOptionsKey.annotation]
        )
        return false
    }
}

public class SwiftZaloSharePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter.io/zalo_share", binaryMessenger: registrar.messenger())
    let instance = SwiftZaloSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "zalo_share" {
            result("Method Call!")
        }
      else if call.method == "init" {
              initZalo(result)
          }
      else if call.method == "logIn" {
            loginZalo(result)
          }
        else {
            result(FlutterMethodNotImplemented)
            return
        }
  }
    
    func initZalo(_ result: FlutterResult) {
        let zaloAppID = Bundle.main.object(forInfoDictionaryKey: "ZaloAppID") as? String
        print("\(zaloAppID ?? "")")
        ZaloSDK.sharedInstance().initialize(withAppId: zaloAppID)
        result(NSNumber(value: 1))
    }
    
    func genCodeVerifier() -> String {
        return SecureRandom(length: 43).toBase64()
    }
    
    func SecureRandom(length: Int) -> String {
        let allowedChars = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
        let allowedCharsCount = UInt32(allowedChars.count)
        var randomString = ""

        for _ in 0 ..< length {
            let randomNum = Int(arc4random_uniform(allowedCharsCount))
            let randomIndex = allowedChars.index(allowedChars.startIndex, offsetBy: randomNum)
            let newCharacter = allowedChars[randomIndex]
            randomString += String(newCharacter)
        }

        return randomString
    }
    
    func loginZalo(_ result: @escaping FlutterResult) {
        ZaloSDK.sharedInstance().unauthenticate()
        guard let rootViewController:UIViewController = UIApplication.shared.keyWindow?.rootViewController else {return}
        let code_verifier = genCodeVerifier()
        let code_challenge:String = code_verifier.data(using: .ascii)!.sha256.toBase64()
        ZaloSDK.sharedInstance().authenticateZalo(with: ZAZAloSDKAuthenTypeViaZaloAppAndWebView, parentController: rootViewController, codeChallenge: code_challenge, extInfo: nil) { response in
            if response?.isSucess == true {
                var resultDic:[String:Any] = [:]
                resultDic["userId"] = response?.userId ?? nil
                resultDic["oauthCode"] = response?.oauthCode ?? nil
                resultDic["errorCode"] = response?.errorCode ?? nil
                resultDic["errorMessage"] = response?.errorMessage ?? nil
                resultDic["displayName"] = response?.displayName ?? nil
                resultDic["dob"] = response?.dob ?? nil
                resultDic["gender"] = response?.gender ?? nil
                result(resultDic)
            } else if let response = response,
                      response.errorCode != -7035 {
                var resultDic:[String:Any] = [:]
                resultDic["errorCode"] = response.errorCode
                resultDic["errorMessage"] = response.errorMessage ?? nil
                result(resultDic)
            }
        }
    }
}
class ZaloShare: NSObject {
    var result:FlutterResult!
    var message:String = ""
    var urlShare:String = ""
    var oauthCode:String = ""

    func share() {
        if oauthCode != "" {
            self.getAccessToken(with: oauthCode)
        }
        else {
            self.result("Null Access Token")
        }
    }
    private func getAccessToken(with oauthCode: String) {
        guard let path = Bundle.main.path(forResource: "Info", ofType: "plist"),
            let infoPlist = NSDictionary(contentsOfFile: path) else { return }
        if let zaloAppId:String = infoPlist.value(forKey: "ZaloAppID") as? String , let zaloAppKey:String = infoPlist.value(forKey: "ZaloAppKey") as? String   {
            let url = URL(string: "https://oauth.zaloapp.com/v3/access_token?app_id=\(zaloAppId)&app_secret=\(zaloAppKey)&code=\(oauthCode)")!
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            let task = URLSession.shared.dataTask(with: request) { data, response, error in
                guard let data = data, error == nil else {
                    print(error?.localizedDescription ?? "No data")
                    self.result("Null Response Access Token")
                    return
                }
                let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                if let responseJSON = responseJSON as? [String: Any] {
                    print(responseJSON)
                    if let accessToken = responseJSON["access_token"] as? String {
                        self.callShareApi(with: accessToken)
                    }
                    else {
                        self.result("Null Response Access Token")
                    }
                }
            }
            task.resume()
        }
        else {
            self.result("Null Info Plist")
        }
    }
    private func callShareApi(with accessToken: String) {
                let url = URL(string: "https://graph.zalo.me/v2.0/me/feed?access_token=\(accessToken)&message=\(message)&link=\(urlShare)")!
                var request = URLRequest(url: url)
                request.httpMethod = "POST"
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
                let task = URLSession.shared.dataTask(with: request) { data, response, error in
                    guard let data = data, error == nil else {
                        print(error?.localizedDescription ?? "No data")
                        return
                    }
                    let responseJSON = try? JSONSerialization.jsonObject(with: data, options: [])
                    if let responseJSON = responseJSON as? [String: Any] {
                        print(responseJSON)
                        if (responseJSON["id"] as? String) != nil {
                            self.result("Share Successful!")
                        }
                        else {
                            self.result("Share Fail Null Id")
                        }
                    }
                    else {
                        self.result("Share Fail")
                    }
                }
                task.resume()
    }
}
extension UIApplication {
    class func getTopViewController(base: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {

        if let nav = base as? UINavigationController {
            return getTopViewController(base: nav.visibleViewController)

        } else if let tab = base as? UITabBarController, let selected = tab.selectedViewController {
            return getTopViewController(base: selected)

        } else if let presented = base?.presentedViewController {
            return getTopViewController(base: presented)
        }
        return base
    }
}

private func hexString(_ iterator: Array<UInt8>.Iterator) -> String {
    return iterator.map { String(format: "%02x", $0) }.joined()
}

extension Data {
    public var sha256: String {
        if #available(iOS 13.0, *) {
            return hexString(SHA256.hash(data: self).makeIterator())
        } else {
            var digest = [UInt8](repeating: 0, count: Int(CC_SHA256_DIGEST_LENGTH))
            self.withUnsafeBytes { bytes in
                _ = CC_SHA256(bytes.baseAddress, CC_LONG(self.count), &digest)
            }
            return hexString(digest.makeIterator())
        }
    }

}

extension String {
    func fromBase64() -> String? {
        guard let data = Data(base64Encoded: self) else {
            return nil
        }

        return String(data: data, encoding: .utf8)
    }
    func toBase64() -> String {
        return Data(self.utf8).base64EncodedString()
    }

}
