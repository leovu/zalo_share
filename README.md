# zalo_share

A new flutter plugin project.

## Android 

# build.gradle
dependencies {
    implementation "me.zalo:sdk-core:+"
    implementation "me.zalo:sdk-auth:+"
    implementation "me.zalo:sdk-openapi:+"
}
# Main Activity

    import com.zing.zalo.zalosdk.oauth.ZaloSDK

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
            super.onActivityResult(requestCode, resultCode, data)
          ZaloSDK.Instance.onActivityResult(this, requestCode, resultCode, data)
            if (requestCode == 0) {
                if (resultCode == Activity.RESULT_OK) {
                    val result = data!!.getStringExtra("result")
                    methodChannelResult.success(result)
                }
                else {
                    methodChannelResult.success(null)
                }
            }
        }
    
# Manifest 
 <!-- ZALO -->
      <meta-data
        android:name="com.zing.zalo.zalosdk.appID"
        android:value="@string/appID" />
      <activity
        android:name="com.zing.zalo.zalosdk.oauth.BrowserLoginActivity">
        <intent-filter>
          <action android:name="android.intent.action.VIEW"/>
          <category android:name="android.intent.category.DEFAULT"/>
          <category android:name="android.intent.category.BROWSABLE"/>
          <data android:scheme="@string/zalosdk_login_protocol_schema"/>
        </intent-filter>
      </activity>

## iOS 
# App Delegate  
import zalo_share


 override func application(
            _ application: UIApplication,
            open url: URL,
            sourceApplication: String?,
            annotation: Any
        ) -> Bool {
            return Zalo.application(application,
                open: url,
                sourceApplication: sourceApplication,
                annotation: annotation
            )
        }

        @available(iOS 9.0, *)
        override func application(
            _ app: UIApplication,
            open url: URL,
            options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {

            return Zalo
                .application(app,
                open: url,
                                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as! String?,
                                annotation: options[UIApplication.OpenURLOptionsKey.annotation]
            )
        }
      }
