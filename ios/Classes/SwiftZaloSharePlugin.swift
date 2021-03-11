import Flutter
import UIKit

public class SwiftZaloSharePlugin: NSObject, FlutterPlugin {
  public static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: "flutter.io/zalo_share", binaryMessenger: registrar.messenger())
    let instance = SwiftZaloSharePlugin()
    registrar.addMethodCallDelegate(instance, channel: channel)
  }

  public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    if call.method == "zalo_share" {
            result("Method Call!");
        }
        else {
            result(FlutterMethodNotImplemented);
            return
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
