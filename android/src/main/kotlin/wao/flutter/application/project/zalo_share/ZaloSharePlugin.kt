package wao.flutter.application.project.zalo_share

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.io.BufferedReader
import java.io.InputStreamReader
import java.io.OutputStreamWriter
import java.net.HttpURLConnection
import java.net.URL
import org.json.JSONObject

/** ZaloSharePlugin */
class ZaloSharePlugin: FlutterPlugin, MethodCallHandler, ActivityAware  {
  /// The MethodChannel that will the communication between Flutter and native Android
  ///
  /// This local reference serves to register the plugin with the Flutter Engine and unregister it
  /// when the Flutter Engine is detached from the Activity
  private lateinit var channel : MethodChannel
  private lateinit var context: Context
  private lateinit var activity: Activity
  private lateinit var result: MethodChannel.Result
  private var zaloAppId: String? = null
  private var zaloAppKey: String? = null
  private var message: String? = null
  private var urlShare: String? = null
  private var oauthCode: String? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    context = flutterPluginBinding.applicationContext
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter.io/zalo_share")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    if (call.method == "zalo_share") {
      this.result = result
      var obj:Map<String,String> = call.arguments()
      zaloAppId = obj["zaloAppId"]
      zaloAppKey = obj["zaloAppKey"]
      message = obj["message"]
      urlShare = obj["urlShare"]
      oauthCode = obj["oauthCode"]
      share()
    } else {
      result.notImplemented()
    }
  }

  override fun onDetachedFromActivity() {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }

  private fun share() {
    if (oauthCode != null) {
      if(zaloAppId != null && zaloAppKey != null) {
        getAccessToken(oauthCode!!)
      }
      else {
        result.success("Null zaloAppId & zaloAppKey")
      }
    }
    else {
      result.success("Null Oauth Code")
    }
  }

  private fun callShareApi(accessToken: String) {
    val mURL = URL("https://graph.zalo.me/v2.0/me/feed?access_token=${accessToken}&message=${message}&link=${urlShare}")
    with(mURL.openConnection() as HttpURLConnection) {
      requestMethod = "POST"
      val wr = OutputStreamWriter(getOutputStream());
      wr.flush();
      println("URL : $url")
      println("Response Code : $responseCode")
      BufferedReader(InputStreamReader(inputStream)).use {
        val response = StringBuffer()
        var inputLine = it.readLine()
        while (inputLine != null) {
          response.append(inputLine)
          inputLine = it.readLine()
        }
        val jsonObj = JSONObject(response.substring(response.indexOf("{"), response.lastIndexOf("}") + 1))
        print(jsonObj)
        val id:String? = jsonObj["id"] as? String
        if(id != null) {
          result.success("Share Successful!")
        }
        else {
          result.success("Share Fail Null Id")
        }
      }
    }
  }

  private fun  getAccessToken(oauthCode: String) {
    val mURL = URL("https://oauth.zaloapp.com/v3/access_token?app_id=${zaloAppId}&app_secret=${zaloAppKey}&code=${oauthCode}")
    with(mURL.openConnection() as HttpURLConnection) {
      requestMethod = "GET"
      val wr = OutputStreamWriter(getOutputStream());
      wr.flush();
      println("URL : $url")
      println("Response Code : $responseCode")
      BufferedReader(InputStreamReader(inputStream)).use {
        val response = StringBuffer()
        var inputLine = it.readLine()
        while (inputLine != null) {
          response.append(inputLine)
          inputLine = it.readLine()
        }
        val jsonObj = JSONObject(response.substring(response.indexOf("{"), response.lastIndexOf("}") + 1))
        print(jsonObj)
        val access_token:String? = jsonObj["access_token"] as? String
        if(access_token != null) {
          callShareApi(access_token)
        }
        else {
          result.success("Null Response Access Token")
        }
      }
    }
  }

}
