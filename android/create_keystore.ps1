<#
PowerShell script to create an Android keystore and write android/key.properties.
Run this script from project root in PowerShell (Windows):

  cd "${PSScriptRoot}\.."
  powershell -ExecutionPolicy Bypass -File android\create_keystore.ps1

The script prompts for alias and passwords and requires `keytool` available in PATH (JDK).
#>

function Read-Secret([string]$prompt) {
    Write-Host -NoNewline "$prompt: "
    $secure = Read-Host -AsSecureString
    return [Runtime.InteropServices.Marshal]::PtrToStringAuto([Runtime.InteropServices.Marshal]::SecureStringToBSTR($secure))
}

if (-not (Get-Command keytool -ErrorAction SilentlyContinue)) {
    Write-Error "keytool not found in PATH. Install JDK and ensure keytool is available."
    exit 1
}

$alias = Read-Host "Enter key alias (default: key0)"
if ([string]::IsNullOrWhiteSpace($alias)) { $alias = 'key0' }
$storePass = Read-Secret "Enter keystore password"
$keyPass = Read-Secret "Enter key password (press Enter to use same as keystore)"
if ([string]::IsNullOrWhiteSpace($keyPass)) { $keyPass = $storePass }

$keystorePath = Join-Path -Path $PSScriptRoot -ChildPath 'keystore.jks'

Write-Host "Generating keystore at: $keystorePath"

$dname = "CN=App Maker, OU=Dev, O=AppMaker, L=Tokyo, S=Tokyo, C=JP"

$cmd = @(
    'keytool', '-genkeypair', '-v',
    '-keystore', """$keystorePath""",
    '-storetype', 'JKS',
    '-alias', $alias,
    '-keyalg', 'RSA',
    '-keysize', '2048',
    '-validity', '10000',
    '-storepass', $storePass,
    '-keypass', $keyPass,
    '-dname', """$dname"""
)

& $cmd

if ($LASTEXITCODE -ne 0) {
    Write-Error "keytool failed (exit $LASTEXITCODE). Keystore not created."
    exit $LASTEXITCODE
}

$propsPath = Join-Path -Path $PSScriptRoot -ChildPath 'key.properties'
@"
storePassword=$storePass
keyPassword=$keyPass
keyAlias=$alias
storeFile=keystore.jks
"@ | Out-File -FilePath $propsPath -Encoding utf8 -Force

Write-Host "Created keystore and wrote android/key.properties. Keep passwords secure and do not commit key.properties to public repos."
