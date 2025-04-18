param(
    [switch]$run
)

################################################################################
## Firefox Security Toolkit - Windows PowerShell Version
## Description:
# This script automatically transforms Firefox Browser to a penetration testing suite.
# The script mainly focuses on downloading the required and useful add-ons for web-application penetration testing.
# You can decide where you want to install an addon or not directly on firefox
## Version:
# v0.1
## Homepage:
# https://github.com/py4rce/Firefox-Security-Toolkit


# Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
# .\firefox_security_toolkit.ps1 -run


################################################################################

# Color definitions for Windows PowerShell
 

function Show-Logo {
    Write-Host @"
    ______ _              ____                _____                           _  __            ______               __ __ __  _  __ 
   / ____/(_)_____ ___   / __/____   _  __   / ___/ ___   _____ __  __ _____ (_)/ /_ __  __   /_  __/____   ____   / // //_/ (_)/ /_
  / /_   / // ___// _ \ / /_ / __ \ | |/_/   \__ \ / _ \ / ___// / / // ___// // __// / / /    / /  / __ \ / __ \ / // ,<   / // __/
 / __/  / // /   /  __// __// /_/ /_>  <    ___/ //  __// /__ / /_/ // /   / // /_ / /_/ /    / /  / /_/ // /_/ // // /| | / // /_  
/_/    /_//_/    \___//_/   \____//_/|_|   /____/ \___/ \___/ \__,_//_/   /_/ \__/ \__, /    /_/   \____/ \____//_//_/ |_|/_/ \__/  
                                                                                 /____/                                            
v0.1
github.com/py4rce
"@
}

function Show-Welcome {
    Write-Host "`n`nUsage:`n`t"
    Write-Host ".\firefox_security_toolkit.ps1 -run"
    Write-Host "`n[%%] Available Add-ons:"
    Write-Host " * Copy PlainText
* Link Gopher
* Copy All Tab URL
* SNAP Links
* Open multiple Links
* CSRF Spotter
* Easy XSS
* FlagFox
* FoxyProxy
* Google Dork Builder
* Hackbar V2
* Hackbar Quantum
* WEB RTC
* HTTP Header Live
* JSON View
* KNOXSS Community Edition
* Redurrect Pages
* Shodan.io
* User-Agent Switcher and manager
* Wappalyzer
* WebDeveloper
* XML ViewerPlus
* HackTools
* PostMessageTracker `n"

    Write-Host "[%%] Additions & Features:"
    Write-Host " * Downloading Burp Suite certificate "
    Write-Host " * Downloading a large user-agent list for User-Agent Switcher `n`n"
    Write-Host "[$] Legal Disclaimer: Usage of Firefox Security Toolkit for attacking targets without prior mutual consent is illegal. It is the end user's responsibility to obey all applicable local, state and federal laws. Developers assume no liability and are not responsible for any misuse or damage caused by this program"
}
 

Show-Logo

if (-not $run) {
    Show-Welcome
    exit
}

Write-Host "`n`n[#] Press Enter to start..." -NoNewline
$null = Read-Host

# Find Firefox installation path
$firefoxPath = (Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\App Paths\firefox.exe" -ErrorAction SilentlyContinue).'(Default)'
if (-not $firefoxPath) {
    Write-Host "[*] Firefox does not seem to be installed.`n[*]Quitting..."
    exit 1
}

Write-Host "${RED}[*] Firefox path: $firefoxPath${NC}"

# Create temporary directory
$scriptPath = [System.IO.Path]::GetTempPath() + [System.Guid]::NewGuid().ToString()
New-Item -ItemType Directory -Path $scriptPath | Out-Null
Write-Host "${RED}[*] Created a tmp directory at [$scriptPath].${NC}"

# Create installation finished page
$installFinishedHtml = @"
<!DOCTYPE HTML><html><center><head><h1>Installation is Finished</h1></head><body><p><h2>You can close Firefox.</h2><h3><i>Firefox Security Toolkit</i></h3></p></body></center></html>
"@
$installFinishedHtml | Out-File "$scriptPath\.installation_finished.html"

# Download Burp certificate if requested
Write-Host "${ORANGE}[@] Would you like to download Burp Suite certificate? [y/n]. (Note: Burp Suite should be running in your machine): ${NC}" -NoNewline
$burpCertAnswer = Read-Host
if ($burpCertAnswer -eq 'y') {
    $burpPort = Read-Host "[@] Enter Burp Suite proxy listener's port (Default: 8080)"
    if (-not $burpPort) { $burpPort = "8080" }
    
    try {
        Invoke-WebRequest "http://127.0.0.1:$burpPort/cert" -OutFile "$scriptPath\cacert.der"
        Write-Host "[*] Burp Suite certificate has been downloaded, and can be found at [$scriptPath\cacert.der]."
    }
    catch {
        Write-Host "[!]Error: Firefox Security Toolkit was not able to download Burp Suite certificate, you need to do this task manually."
    }
}

# Function to download Firefox extensions
function Download-Extension {
    param(
        [string]$url,
        [string]$outputFile
    )
    try {
        Invoke-WebRequest -Uri $url -OutFile "$scriptPath\$outputFile"
        Write-Host "Downloaded: $outputFile"
    }
    catch {
        Write-Host "Failed to download: $outputFile"
    }
}

# Download extensions
Write-Host "[*] Downloading Add-ons."

# List of extensions to download
$extensions = @{
    "web_developer-3.0.1.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4306323/web_developer-3.0.1.xpi"
    "link_gopher-2.6.2.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4183832/link_gopher-2.6.2.xpi"
    "copy_all_tab_urls_we-2.2.0.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3988710/copy_all_tab_urls_we-2.2.0.xpi"
    "snaplinksplus-3.1.15.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4393740/snaplinksplus-3.1.15.xpi"
    "open_multiple_urls-1.7.4.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4444103/open_multiple_urls-1.7.4.xpi"
    "copy_plaintext-1.15.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4143512/copy_plaintext-1.15.xpi"
    "csrf_spotter-1.0.xpi" = "https://addons.mozilla.org/firefox/downloads/file/2209785/csrf_spotter-1.0.xpi"
    "easy_xss-1.0-fx.xpi" = "https://addons.mozilla.org/firefox/downloads/file/1158849/easy_xss-1.0-fx.xpi"
    "flagfox-6.1.83.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4428652/flagfox-6.1.83.xpi"
    "foxyproxy_standard-8.10.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4425860/foxyproxy_standard-8.10.xpi"
    "google_dork_builder-0.9.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3864393/google_dork_builder-0.9.xpi"
    "hackbar_free-2.5.4.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4399104/hackbar_free-2.5.4.xpi"
    "quantum_hackbar-1.0.2resigned1.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4274533/quantum_hackbar-1.0.2resigned1.xpi"
    "happy_bonobo_disable_webrtc-1.0.23.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3551985/happy_bonobo_disable_webrtc-1.0.23.xpi"
    "http_header_live-0.6.5.2.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3384326/http_header_live-0.6.5.2.xpi"
    "jsonview-3.1.0.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4419512/jsonview-3.1.0.xpi"
    "knoxss_community_edition-0.2.0.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3378216/knoxss_community_edition-0.2.0.xpi"
    "resurrect_pages-8.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3640440/resurrect_pages-8.xpi"
    "shodan_addon-1.1.1.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4117305/shodan_addon-1.1.1.xpi"
    "user_agent_string_switcher-0.5.0.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4098688/user_agent_string_switcher-0.5.0.xpi"
    "wappalyzer-6.10.79.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4431384/wappalyzer-6.10.79.xpi"
    "xml_viewer-1.2.6.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3032172/xml_viewer-1.2.6.xpi"
    "hacktools-0.3.2-fx.xpi" = "https://addons.mozilla.org/firefox/downloads/file/3901885/hacktools-0.4.0.xpi"
    "postmessage_tracker_f-1.1.2.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4226437/postmessage_tracker_f-1.1.2.xpi"
}

foreach ($extension in $extensions.GetEnumerator()) {
    Download-Extension -url $extension.Value -outputFile $extension.Name
}

# Ask for my daily extensions
Write-Host "[@] Would you like to download my daily extensions that I personally use? [y/n]: " -NoNewline
$dailyUseAnswer = Read-Host

if ($dailyUseAnswer -eq 'y') {
    $dailyExtensions = @{
        "darkreader-4.9.103.xpi" = "https://addons.mozilla.org/firefox/downloads/file/4439735/darkreader-4.9.103.xpi"
    }

    foreach ($extension in $dailyExtensions.GetEnumerator()) {
        Download-Extension -url $extension.Value -outputFile $extension.Name
    }
    Write-Host "[*]Additional extensions has been installed."
}

# Install extensions
Write-Host "[*] Downloading add-ons completed.`n"
Write-Host "[@@] Press Enter to run Firefox to perform the task. (Note: Firefox will be restarted)" -NoNewline
$null = Read-Host
Write-Host "[*] Running Firefox to install the add-ons.`n"
Write-Host "Click confirm on the prompt, and close Firefox, until all addons are installed"

# Stop Firefox if running
Stop-Process -Name "firefox" -ErrorAction SilentlyContinue

# Install extensions
Get-ChildItem -Path $scriptPath -Filter "*.xpi" | ForEach-Object {
    Write-Host "- $($_.FullName)"
    Start-Process $firefoxPath -ArgumentList "--new-tab", $_.FullName
}

Start-Process $firefoxPath -ArgumentList "$scriptPath\.installation_finished.html"

Write-Host "[**] Firefox Security Toolkit is finished`n"
Write-Host "Have a nice day!"
