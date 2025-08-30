@HiltAndroidApp // ถ้าใช้ Hilt; ถ้าไม่ใช้ ลบแอนโนเตชันนี้ได้
class App : Application() {
  override fun onCreate() {
    super.onCreate()
    Firebase.initialize(this)
    Firebase.appCheck.installAppCheckProviderFactory(
      PlayIntegrityAppCheckProviderFactory.getInstance()
    )
  }
}
