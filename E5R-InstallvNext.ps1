$NUGET_BASE=Join-Path $env:LocalAppData "NuGet"
$NUGET_PATH=Join-Path $NUGET_BASE "NuGet.exe"
$E5R_BASE=Join-Path $env:USERPROFILE ".E5R"
$E5R_TOOLS=Join-Path $E5R_BASE "tools"
$NUGET_LOCAL_PATH=Join-Path $E5R_TOOLS "NuGet.exe"
$E5R_PACKAGES=Join-Path $E5R_BASE "packages"
$CMD_NUGET=$NUGET_LOCAL_PATH
$KLRVERSION = "1.0.0-alpha4-10285"
$KVM_PATH=Join-Path $env:USERPROFILE ".kre\packages\KRE-{TYPE}-{ARCH}.$KLRVERSION"
$NUGET_KREPATH=Join-Path $env:USERPROFILE ".kre\bin\NuGet.exe"
$KVMPS = Join-Path $E5R_TOOLS "kvm.ps1"
$KVMCMD = Join-Path $E5R_TOOLS "kvm.cmd"
$KLRE5RDEV = "e5r"

Function Path-For(){
param(
    [string] $type,
    [string] $arch
)
    $replaced = $KVM_PATH
    $replaced = $replaced -replace "{TYPE}", $type
    $replaced = $replaced -replace "{ARCH}", $arch
    return $replaced
}

Function Copy-NuGet() {
    if((Test-Path $E5R_TOOLS) -ne 1){
        New-Item -ItemType Directory -Force -Path $E5R_TOOLS
    }
    Copy-Item -Path $NUGET_PATH -Destination $NUGET_LOCAL_PATH
}

Function Install-NuGet() {
    if((Test-Path $NUGET_LOCAL_PATH) -eq 1){
        return
    }
    if((Test-Path $NUGET_BASE) -ne 1){
        New-Item -ItemType Directory -Force -Path $NUGET_BASE
    }
    if((Test-Path $NUGET_PATH) -ne 1){
        Write-Host "Downloading latest version of NuGet.exe..."
        Invoke-WebRequest 'https://www.nuget.org/nuget.exe' -OutFile $NUGET_PATH
    }
    Copy-NuGet
}

Function Install-KVM(){
    if((Test-Path $KVMPS) -ne 1){
        Write-Host "Downloading KVM.ps1..."
        Invoke-WebRequest 'https://raw.githubusercontent.com/aspnet/kvm/dev/src/kvm.ps1' -OutFile $KVMPS
    }
    if((Test-Path $KVMCMD) -ne 1){
        Write-Host "Downloading KVM.cmd..."
        Invoke-WebRequest 'https://raw.githubusercontent.com/aspnet/kvm/dev/src/kvm.cmd' -OutFile $KVMCMD
    }

    Write-Host "Installing KRuntime's"

    $installpath = Path-For -type "svr50" -arch "x86"
    if((Test-Path $installpath) -ne 1){
        Write-Host ""
        Write-Host "KRE [Net45] x86"
        Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x86 -svr50 -persistent"
    }

    $installpath = Path-For -type "svrc50" -arch "x86"
    if((Test-Path $installpath) -ne 1){
        Write-Host ""
        Write-Host "KRE [Core] x86"
        Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x86 -svrc50"
    }

    $installpath = Path-For -type "svr50" -arch "x64"
    if((Test-Path $installpath) -ne 1){
        Write-Host ""
        Write-Host "KRE [Net45] x64"
        Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x64 -svr50"
    }

    $installpath = Path-For -type "svrc50" -arch "x64"
    if((Test-Path $installpath) -ne 1){
        Write-Host ""
        Write-Host "KRE [Core] x64"
        Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x64 -svrc50"
    }

    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x86 $KLRVERSION -x86 -svr50"                  #kvm use e5r-x86
    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x86-core $KLRVERSION -x86 -svrc50"            #kvm use e5r-x86-core
    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x64 $KLRVERSION -x64 -svr50"                  #kvm use e5r-x64
    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x64-core $KLRVERSION -x64 -svrc50"            #kvm use e5r-x64-core
    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV $KLRE5RDEV-x86"                               #kvm use e5r
    Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-core $KLRE5RDEV-x86-core"                     #kvm use e5r-core

    Write-Host ""
    Write-Host "Set default [Net45 x86]"
    Invoke-Expression -Command:"$KVMCMD setup"
    Invoke-Expression -Command:"$KVMCMD use $KLRE5RDEV"      #Set default [e5r]

    Write-Host ""
    Write-Host "Configurations"
    Write-Host "------------------------------------------------------------------"
    Invoke-Expression -Command:"$KVMCMD list"
    Write-Host "------------------------------------------------------------------"

    if((Test-Path $NUGET_LOCAL_PATH) -eq 1){
        Copy-Item -Path $NUGET_LOCAL_PATH -Destination $NUGET_KREPATH
        Remove-Item $NUGET_LOCAL_PATH
    }
    if((Test-Path $KVMPS) -eq 1){
        Remove-Item $KVMPS
    }
    if((Test-Path $KVMCMD) -eq 1){
        Remove-Item $KVMCMD
    }
    if((Test-Path $E5R_BASE) -eq 1){
        Remove-Item $E5R_BASE -Recurse
    }
}

Function Restore-Package($package, $version = ""){
    $packagename = $package
    $paramversion = "-ExcludeVersion"
    if($version -ne ""){
        $paramversion = "-Version $version"
        $packagename = "$packagename.$version"
    }
    $packagepath = Join-Path $E5R_PACKAGES $packagename
    if((Test-Path $packagepath) -ne 1){
        Write-Host "Restore package $packagename..."
        $command = "$CMD_NUGET install $package $paramversion -o $E5R_PACKAGES -NoCache -Prerelease"
        Invoke-Expression -Command:$command
    }
}

Function Run(){
    Install-NuGet
    Install-KVM
    #Restore-Package "KoreBuild"
}

Run
