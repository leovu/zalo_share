package wao.flutter.application.project.zalo_share

import android.app.Activity
import android.content.Context
import android.os.Build
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import com.zing.zalo.zalosdk.core.helper.AppInfo.getApplicationHashKey
import com.zing.zalo.zalosdk.oauth.*
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import java.security.MessageDigest
import java.security.SecureRandom
import java.util.*
import java.util.Locale.US
import kotlin.collections.HashMap


/** ZaloSharePlugin */
class ZaloSharePlugin: FlutterPlugin, MethodCallHandler, ActivityAware  {
  private var _context: Context? = null
  private var _activity: Activity? = null
  private val _mSDk = ZaloSDK.Instance
  private var _result: MethodChannel.Result? = null

  private var _channel: MethodChannel? = null

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    _context = flutterPluginBinding.applicationContext
    _channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter.io/zalo_share")
    _channel!!.setMethodCallHandler(this)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
    _result = result
    if (call.method.equals("init")) {
      val hashkey = getApplicationHashKey(_context)
      _result!!.success(hashkey)
    } else if (call.method.equals("logIn")) {
      _mSDk.unauthenticate()
      val listener: OAuthCompleteListener = object : OAuthCompleteListener() {
        override fun onGetOAuthComplete(response: OauthResponse) {
          val result: MutableMap<String, Any> = HashMap()
          result["userId"] = response.getuId()
          result["oauthCode"] = response.oauthCode
          result["errorCode"] = response.errorCode
          result["errorMessage"] = response.errorMessage
          _result!!.success(result)
        }
        fun onAuthenError(errorCode: Int, message: String) {
          val result: MutableMap<String, Any> = HashMap()
          result["errorCode"] = errorCode
          result["errorMessage"] = message
          _result!!.success(result)
        }
      }
      val codeVerifier = genCodeVerifier()
      val codeChallenge = codeVerifier?.let { genCodeChallenge(it) }
      _mSDk.authenticateZaloWithAuthenType(_activity, LoginVia.APP_OR_WEB, codeChallenge, listener)
    } else {
      _result!!.notImplemented()
    }
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun genCodeVerifier(): String? {
    val sr = SecureRandom()
    val code = ByteArray(32)
    sr.nextBytes(code)
    return Base64.getUrlEncoder().withoutPadding().encodeToString(code)
  }

  @RequiresApi(Build.VERSION_CODES.O)
  private fun genCodeChallenge(codeVerifier: String): String? {
    var result: String? = null
    try {
      val bytes: ByteArray = codeVerifier.toByteArray()
      val md: MessageDigest = MessageDigest.getInstance("SHA-256")
      md.update(bytes, 0, bytes.size)
      val digest: ByteArray = md.digest()
      result = Base64.getUrlEncoder().withoutPadding().encodeToString(digest)
    } catch (ex: Exception) {
      print(ex.message)
    }
    return result
  }

  override fun onDetachedFromActivity() {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    _activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
//     TODO("not implemented") //To change body of created functions use File | Settings | File Templates.
  }
  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    _channel?.setMethodCallHandler(null)
  }

}
