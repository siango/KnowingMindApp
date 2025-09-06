$ErrorActionPreference = "Stop"

function Info($msg){ Write-Host "[INFO]  $msg" -ForegroundColor Cyan }
function Ok($msg){   Write-Host "[OK]    $msg" -ForegroundColor Green }
function Warn($msg){ Write-Host "[WARN]  $msg" -ForegroundColor Yellow }
function Err($msg){  Write-Host "[ERROR] $msg" -ForegroundColor Red }

function Get-Cmd($name){
  try { return (Get-Command $name -ErrorAction SilentlyContinue) } catch { return $null }
}
function Get-Version($cmd, $args=@("--version")){
  try{ (& $cmd @args 2>&1 | Out-String) -replace '\r?\n } catch { return $null }
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
Info "Project root: $Root"

# 1) Git
$gitCmd = Get-Cmd git
if ($gitCmd) { Ok ("Git: " + (Get-Version git)) } else { Warn "Git not found" }

# 2) Java/JDK (need 17+ for AGP 8.x)
$javaCmd = Get-Cmd java
if ($javaCmd) {
  $javaVerRaw = & java -version 2>&1 | Out-String
  $m = [regex]::Match($javaVerRaw, 'version "(\d+)(\.\d+)?')
  if ($m.Success) {
    $major = [int]$m.Groups[1].Value
    if ($major -ge 17) { Ok ("Java: " + $javaVerRaw.Trim()) } else { Warn ("Java < 17: " + $javaVerRaw.Trim()) }
  } else { Warn ("Java version unreadable: " + $javaVerRaw.Trim()) }
} else { Err "Java/JDK not found (need JDK 17+)" }

# 3) Android SDK
$androidHome = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { $null }
if ($androidHome -and (Test-Path $androidHome)) {
  Ok "Android SDK: $androidHome"
  $btDir = Join-Path $androidHome "build-tools"
  if (Test-Path $btDir) {
    $buildTools = Get-ChildItem -ErrorAction SilentlyContinue $btDir | Sort-Object Name -Descending | Select-Object -First 1
    if ($buildTools) { Ok ("Build-tools: " + $buildTools.Name) } else { Warn "No build-tools found" }
  } else { Warn "build-tools directory not found" }
} else { Warn "ANDROID_HOME/ANDROID_SDK_ROOT not set or invalid" }

# 4) Gradle wrapper
$hasGradlew = Test-Path ".\gradlew"
$hasWrapperProps = Test-Path ".\gradle\wrapper\gradle-wrapper.properties"
if ($hasGradlew -and $hasWrapperProps) {
  try {
    $props = Get-Content ".\gradle\wrapper\gradle-wrapper.properties" -Raw
    $m = [regex]::Match($props, 'distributionUrl=.*gradle-([\d\.]+)-')
    if ($m.Success) { Ok ("Gradle wrapper: " + $m.Groups[1].Value) } else { Ok "Gradle wrapper: properties found" }
  } catch {
    Warn "Unable to read gradle-wrapper.properties: $($_.Exception.Message)"
  }
} else {
  Err "Gradle wrapper missing (gradlew and/or wrapper properties)"
}

# 5) Node / npm
$nodeCmd = Get-Cmd node
if ($nodeCmd) { Ok ("Node: " + (Get-Version node -args @("-v"))) } else { Warn "Node not found" }
$npmCmd = Get-Cmd npm
if ($npmCmd)  { Ok ("npm: "  + (Get-Version npm  -args @("-v"))) } else { Warn "npm not found" }

# 6) Python / pip
$pyCmd = Get-Cmd python
if ($pyCmd) { Ok ("Python: " + (Get-Version python -args @("--version"))) } else { Warn "Python not found" }
$pipCmd = Get-Cmd pip
if ($pipCmd) { Ok ("pip: " + (Get-Version pip -args @("--version"))) } else { Warn "pip not found" }

# 7) Android project files
if (Test-Path ".\app\build.gradle" -or Test-Path ".\app\build.gradle.kts") { Ok "Found app/build.gradle*" } else { Err "Missing app/build.gradle(.kts)" }
if (Test-Path ".\settings.gradle" -or Test-Path ".\settings.gradle.kts")  { Ok "Found settings.gradle*" } else { Err "Missing settings.gradle(.kts)" }

# 8) Firebase google-services.json
if (Test-Path ".\app\google-services.json") { Ok "Found app/google-services.json" } else { Warn "app/google-services.json not found (if using Firebase)" }

# 9) Ensure keystore not tracked
try {
  $trackedKeystore = (& git ls-files "*.keystore" "*.jks" 2>$null)
  if ($trackedKeystore) { Warn ("Keystore tracked in repo:`n" + $trackedKeystore + "`nRemove from VCS!") } else { Ok "No keystore tracked" }
} catch { Warn "Git check for keystore failed" }

Write-Host ""
Ok "Preflight complete"
,'' } catch { return $null }
}

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
Set-Location $Root
Info "Project root: $Root"

# 1) Git
$gitCmd = Get-Cmd git
if ($gitCmd) { Ok ("Git: " + (Get-Version git)) } else { Warn "Git not found" }

# 2) Java/JDK (need 17+ for AGP 8.x)
$javaCmd = Get-Cmd java
if ($javaCmd) {
  $javaVerRaw = & java -version 2>&1 | Out-String
  $m = [regex]::Match($javaVerRaw, 'version "(\d+)(\.\d+)?')
  if ($m.Success) {
    $major = [int]$m.Groups[1].Value
    if ($major -ge 17) { Ok ("Java: " + $javaVerRaw.Trim()) } else { Warn ("Java < 17: " + $javaVerRaw.Trim()) }
  } else { Warn ("Java version unreadable: " + $javaVerRaw.Trim()) }
} else { Err "Java/JDK not found (need JDK 17+)" }

# 3) Android SDK
$androidHome = if ($env:ANDROID_HOME) { $env:ANDROID_HOME } elseif ($env:ANDROID_SDK_ROOT) { $env:ANDROID_SDK_ROOT } else { $null }
if ($androidHome -and (Test-Path $androidHome)) {
  Ok "Android SDK: $androidHome"
  $btDir = Join-Path $androidHome "build-tools"
  if (Test-Path $btDir) {
    $buildTools = Get-ChildItem -ErrorAction SilentlyContinue $btDir | Sort-Object Name -Descending | Select-Object -First 1
    if ($buildTools) { Ok ("Build-tools: " + $buildTools.Name) } else { Warn "No build-tools found" }
  } else { Warn "build-tools directory not found" }
} else { Warn "ANDROID_HOME/ANDROID_SDK_ROOT not set or invalid" }

# 4) Gradle wrapper
$hasGradlew = Test-Path ".\gradlew"
$hasWrapperProps = Test-Path ".\gradle\wrapper\gradle-wrapper.properties"
if ($hasGradlew -and $hasWrapperProps) {
  try {
    $props = Get-Content ".\gradle\wrapper\gradle-wrapper.properties" -Raw
    $m = [regex]::Match($props, 'distributionUrl=.*gradle-([\d\.]+)-')
    if ($m.Success) { Ok ("Gradle wrapper: " + $m.Groups[1].Value) } else { Ok "Gradle wrapper: properties found" }
  } catch {
    Warn "Unable to read gradle-wrapper.properties: $($_.Exception.Message)"
  }
} else {
  Err "Gradle wrapper missing (gradlew and/or wrapper properties)"
}

# 5) Node / npm
$nodeCmd = Get-Cmd node
if ($nodeCmd) { Ok ("Node: " + (Get-Version node -args @("-v"))) } else { Warn "Node not found" }
$npmCmd = Get-Cmd npm
if ($npmCmd)  { Ok ("npm: "  + (Get-Version npm  -args @("-v"))) } else { Warn "npm not found" }

# 6) Python / pip
$pyCmd = Get-Cmd python
if ($pyCmd) { Ok ("Python: " + (Get-Version python -args @("--version"))) } else { Warn "Python not found" }
$pipCmd = Get-Cmd pip
if ($pipCmd) { Ok ("pip: " + (Get-Version pip -args @("--version"))) } else { Warn "pip not found" }

# 7) Android project files
if (Test-Path ".\app\build.gradle" -or Test-Path ".\app\build.gradle.kts") { Ok "Found app/build.gradle*" } else { Err "Missing app/build.gradle(.kts)" }
if (Test-Path ".\settings.gradle" -or Test-Path ".\settings.gradle.kts")  { Ok "Found settings.gradle*" } else { Err "Missing settings.gradle(.kts)" }

# 8) Firebase google-services.json
if (Test-Path ".\app\google-services.json") { Ok "Found app/google-services.json" } else { Warn "app/google-services.json not found (if using Firebase)" }

# 9) Ensure keystore not tracked
try {
  $trackedKeystore = (& git ls-files "*.keystore" "*.jks" 2>$null)
  if ($trackedKeystore) { Warn ("Keystore tracked in repo:`n" + $trackedKeystore + "`nRemove from VCS!") } else { Ok "No keystore tracked" }
} catch { Warn "Git check for keystore failed" }

Write-Host ""
Ok "Preflight complete"

