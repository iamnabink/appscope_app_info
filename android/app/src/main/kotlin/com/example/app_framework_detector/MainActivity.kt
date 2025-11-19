package com.example.app_framework_detector

import android.content.Intent
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.net.Uri
import android.os.Build
import android.util.Log
import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.ByteArrayOutputStream
import java.text.SimpleDateFormat
import java.util.Date
import java.util.Locale

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app_scanner"
    private val TAG = "MainActivity"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Method called: ${call.method}")
            when (call.method) {
                "getInstalledApps" -> {
                    try {
                        val apps = getInstalledApps()
                        result.success(apps)
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get installed apps: ${e.message}", null)
                    }
                }
                "getAppDetails" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        if (packageName != null) {
                            val details = getAppDetails(packageName)
                            result.success(details)
                        } else {
                            result.error("ERROR", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        result.error("ERROR", "Failed to get app details: ${e.message}", null)
                    }
                }
                "uninstallApp" -> {
                    try {
                        val packageName = call.argument<String>("packageName")
                        Log.d(TAG, "uninstallApp called with package: $packageName")
                        if (packageName != null) {
                            runOnUiThread {
                                uninstallApp(packageName)
                            }
                            result.success(true)
                        } else {
                            Log.e(TAG, "Package name is null")
                            result.error("ERROR", "Package name is required", null)
                        }
                    } catch (e: Exception) {
                        Log.e(TAG, "Error uninstalling app: ${e.message}", e)
                        result.error("ERROR", "Failed to uninstall app: ${e.message}", null)
                    }
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = applicationContext.packageManager
        val apps = mutableListOf<Map<String, Any?>>()
        
        val flags = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            PackageManager.MATCH_ALL or PackageManager.MATCH_DISABLED_COMPONENTS
        } else {
            @Suppress("DEPRECATION")
            PackageManager.GET_META_DATA or PackageManager.MATCH_DISABLED_COMPONENTS
        }
        
        val installedPackages = packageManager.getInstalledPackages(flags)
        
        for (packageInfo in installedPackages) {
            try {
                val appInfo = packageInfo.applicationInfo ?: continue
                
                // Skip system apps if needed (optional)
                // if ((appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0) continue
                
                val appName = packageManager.getApplicationLabel(appInfo).toString()
                val packageName = packageInfo.packageName
                val apkPath = appInfo.sourceDir
                
                // Get app icon
                val icon = appInfo.loadIcon(packageManager)
                val iconBytes = drawableToByteArray(icon)
                
                apps.add(mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "icon" to iconBytes,
                    "apkPath" to apkPath
                ))
            } catch (e: Exception) {
                // Skip apps that can't be accessed
                continue
            }
        }
        
        return apps
    }

    private fun getAppDetails(packageName: String): Map<String, Any?> {
        val packageManager = applicationContext.packageManager
        val details = mutableMapOf<String, Any?>()
        
        try {
            val packageInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getPackageInfo(packageName, PackageManager.PackageInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getPackageInfo(packageName, 0)
            }
            
            val appInfo = packageInfo.applicationInfo ?: return details
            
            // Basic info
            details["packageName"] = packageName
            details["appName"] = packageManager.getApplicationLabel(appInfo).toString()
            details["apkPath"] = appInfo.sourceDir
            
            // Version info
            details["versionName"] = packageInfo.versionName
            details["versionCode"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toLong()
            }
            
            // Install date
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                val installTime = packageInfo.firstInstallTime
                details["installDate"] = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(installTime))
            } else {
                @Suppress("DEPRECATION")
                val installTime = packageInfo.firstInstallTime
                details["installDate"] = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(installTime))
            }
            
            // App size
            val apkFile = File(appInfo.sourceDir)
            details["apkSize"] = apkFile.length()
            
            // Icon
            val icon = appInfo.loadIcon(packageManager)
            details["icon"] = drawableToByteArray(icon)
            
            // Flags
            details["isSystemApp"] = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            details["isUpdatedSystemApp"] = (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            details["isEnabled"] = appInfo.enabled
            
            // Target SDK
            details["targetSdkVersion"] = appInfo.targetSdkVersion
            
            // Min SDK
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                details["minSdkVersion"] = appInfo.minSdkVersion
            }
            
        } catch (e: Exception) {
            // Return empty map if package not found
        }
        
        return details
    }
    
    private fun uninstallApp(packageName: String) {
        val intent = Intent(Intent.ACTION_DELETE).apply {
            data = Uri.parse("package:$packageName")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        startActivity(intent)
    }

    private fun drawableToByteArray(drawable: Drawable): ByteArray? {
        return try {
            val bitmap = when (drawable) {
                is BitmapDrawable -> drawable.bitmap
                else -> {
                    val bitmap = Bitmap.createBitmap(
                        drawable.intrinsicWidth,
                        drawable.intrinsicHeight,
                        Bitmap.Config.ARGB_8888
                    )
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }
            
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 100, outputStream)
            outputStream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
}

