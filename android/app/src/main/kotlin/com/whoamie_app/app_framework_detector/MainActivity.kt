package com.whoamie_app.appdna

import android.app.usage.UsageStats
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.content.pm.ApplicationInfo
import android.content.pm.PackageInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
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
import kotlinx.coroutines.*

class MainActivity: FlutterActivity() {
    private val CHANNEL = "app_scanner"
    private val TAG = "MainActivity"
    private val ioScope = CoroutineScope(Dispatchers.IO + Job())

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            Log.d(TAG, "Method called: ${call.method}")
            when (call.method) {
                "getInstalledApps" -> {
                    ioScope.launch {
                        try {
                            val apps = getInstalledApps()
                            withContext(Dispatchers.Main) {
                                result.success(apps)
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR", "Failed to get installed apps: ${e.message}", null)
                            }
                        }
                    }
                }
                "getAppDetails" -> {
                    ioScope.launch {
                        try {
                            val packageName = call.argument<String>("packageName")
                            if (packageName != null) {
                                val details = getAppDetails(packageName)
                                withContext(Dispatchers.Main) {
                                    result.success(details)
                                }
                            } else {
                                withContext(Dispatchers.Main) {
                                    result.error("ERROR", "Package name is required", null)
                                }
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR", "Failed to get app details: ${e.message}", null)
                            }
                        }
                    }
                }
                "getAppIcon" -> {
                    ioScope.launch {
                        try {
                            val packageName = call.argument<String>("packageName")
                            if (packageName != null) {
                                val iconBytes = getAppIcon(packageName)
                                withContext(Dispatchers.Main) {
                                    result.success(iconBytes)
                                }
                            } else {
                                withContext(Dispatchers.Main) {
                                    result.error("ERROR", "Package name is required", null)
                                }
                            }
                        } catch (e: Exception) {
                            withContext(Dispatchers.Main) {
                                result.error("ERROR", "Failed to get app icon: ${e.message}", null)
                            }
                        }
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

    override fun onDestroy() {
        super.onDestroy()
        ioScope.cancel()
    }

    private fun getInstalledApps(): List<Map<String, Any?>> {
        val packageManager = applicationContext.packageManager
        val apps = mutableListOf<Map<String, Any?>>()
        val dateFormat = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault())
        
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
                
                val appName = packageManager.getApplicationLabel(appInfo).toString()
                val packageName = packageInfo.packageName
                val apkPath = appInfo.sourceDir
                
                // Fetch usage stats if available
                val usageStatsMap = getUsageStatsMap()
                val usageStats = usageStatsMap[packageName]
                val appUsage = usageStats?.totalTimeInForeground ?: 0L
                val lastUsedDate = if (usageStats != null && usageStats.lastTimeUsed > 0) {
                    dateFormat.format(Date(usageStats.lastTimeUsed))
                } else null

                val installDate = dateFormat.format(Date(packageInfo.firstInstallTime))
                val apkSize = File(appInfo.sourceDir).length()
                
                // Check if system app
                val isSystemApp = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
                val isUpdatedSystemApp = (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
                
                // NOT loading icon here anymore for performance
                
                apps.add(mapOf(
                    "packageName" to packageName,
                    "appName" to appName,
                    "apkPath" to apkPath,
                    "installDate" to installDate,
                    "apkSize" to apkSize,
                    "isSystemApp" to isSystemApp,
                    "isUpdatedSystemApp" to isUpdatedSystemApp,
                    "appUsage" to appUsage,
                    "lastUsedDate" to lastUsedDate
                ))
            } catch (e: Exception) {
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
            
            details["packageName"] = packageName
            details["appName"] = packageManager.getApplicationLabel(appInfo).toString()
            details["apkPath"] = appInfo.sourceDir
            details["versionName"] = packageInfo.versionName
            details["versionCode"] = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                packageInfo.longVersionCode
            } else {
                @Suppress("DEPRECATION")
                packageInfo.versionCode.toLong()
            }
            details["installDate"] = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(packageInfo.firstInstallTime))
            
            // Add usage stats
            val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
            val endTime = System.currentTimeMillis()
            val startTime = endTime - 1000L * 60 * 60 * 24 * 365 // 1 year ago
            val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_BEST, startTime, endTime)
            val appUsageStats = stats?.find { it.packageName == packageName }
            
            details["appUsage"] = appUsageStats?.totalTimeInForeground ?: 0L
            if (appUsageStats != null && appUsageStats.lastTimeUsed > 0) {
                details["lastUsedDate"] = SimpleDateFormat("yyyy-MM-dd HH:mm:ss", Locale.getDefault()).format(Date(appUsageStats.lastTimeUsed))
            }

            details["apkSize"] = File(appInfo.sourceDir).length()
            details["isSystemApp"] = (appInfo.flags and ApplicationInfo.FLAG_SYSTEM) != 0
            details["isUpdatedSystemApp"] = (appInfo.flags and ApplicationInfo.FLAG_UPDATED_SYSTEM_APP) != 0
            details["isEnabled"] = appInfo.enabled
            details["targetSdkVersion"] = appInfo.targetSdkVersion
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                details["minSdkVersion"] = appInfo.minSdkVersion
            }
        } catch (e: Exception) {}
        
        return details
    }
    
    private fun getAppIcon(packageName: String): ByteArray? {
        val packageManager = applicationContext.packageManager
        return try {
            val appInfo = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
                packageManager.getApplicationInfo(packageName, PackageManager.ApplicationInfoFlags.of(0))
            } else {
                @Suppress("DEPRECATION")
                packageManager.getApplicationInfo(packageName, 0)
            }
            val icon = appInfo.loadIcon(packageManager)
            drawableToByteArray(icon)
        } catch (e: Exception) {
            null
        }
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
                    val width = if (drawable.intrinsicWidth > 0) drawable.intrinsicWidth else 128
                    val height = if (drawable.intrinsicHeight > 0) drawable.intrinsicHeight else 128
                    val bitmap = Bitmap.createBitmap(width, height, Bitmap.Config.ARGB_8888)
                    val canvas = Canvas(bitmap)
                    drawable.setBounds(0, 0, canvas.width, canvas.height)
                    drawable.draw(canvas)
                    bitmap
                }
            }
            
            val outputStream = ByteArrayOutputStream()
            bitmap.compress(Bitmap.CompressFormat.PNG, 80, outputStream) // Reduced quality for performance
            outputStream.toByteArray()
        } catch (e: Exception) {
            null
        }
    }
    private fun getUsageStatsMap(): Map<String, UsageStats> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val endTime = System.currentTimeMillis()
        val startTime = endTime - 1000L * 60 * 60 * 24 * 365 // 1 year ago
        
        val stats = usageStatsManager.queryUsageStats(UsageStatsManager.INTERVAL_BEST, startTime, endTime)
        return stats?.associateBy { it.packageName } ?: emptyMap()
    }
}

