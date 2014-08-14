$NUGET_BASE=Join-Path $env:LocalAppData "NuGet"
$NUGET_PATH=Join-Path $NUGET_BASE "NuGet.exe"
$E5R_BASE=Join-Path $env:USERPROFILE ".E5R"
$E5R_TOOLS=Join-Path $E5R_BASE "tools"
$NUGET_LOCAL_PATH=Join-Path $E5R_TOOLS "NuGet.exe"
$E5R_PACKAGES=Join-Path $E5R_BASE "packages"
$CMD_NUGET=$NUGET_LOCAL_PATH
$KVM_PATH=Join-Path $env:USERPROFILE ".kre\bin\kvm.ps1"
$NUGET_KREPATH=Join-Path $env:USERPROFILE ".kre\bin\NuGet.exe"
$KVMPS = Join-Path $E5R_TOOLS "kvm.ps1"
$KVMCMD = Join-Path $E5R_TOOLS "kvm.cmd"
$KLRVERSION = "1.0.0-alpha3"
$KLRE5RDEV = "e5r"

# 
# COPYRIGHT! Este codigo `Change-Path()` e uma copia da funcao com mesmo nome de autoria do time
#            ASP.NET vNext (https://github.com/aspnet/Home/blob/master/kvm.ps1)
#
#            Copyright (c) Microsoft Open Technologies, Inc. All rights reserved.
#            
#            Licensed under the Apache License, Version 2.0 (the "License"); you may not use
#            these files except in compliance with the License. You may obtain a copy of the
#            License at
#            
#            http://www.apache.org/licenses/LICENSE-2.0
#            
#            Unless required by applicable law or agreed to in writing, software distributed
#            under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR
#            CONDITIONS OF ANY KIND, either express or implied. See the License for the
#            specific language governing permissions and limitations under the License.
#
function Change-Path() {
param(
  [string] $existingPaths,
  [string] $prependPath,
  [string[]] $removePaths
)
    $newPath = $prependPath
    foreach($portion in $existingPaths.Split(';')) {
      $skip = $portion -eq ""
      foreach($removePath in $removePaths) {
        if ($portion.StartsWith($removePath)) {
          $skip = $true
        }
      }
      if (!$skip) {
        $newPath = $newPath + ";" + $portion
      }
    }
    return $newPath
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
        Invoke-WebRequest 'https://raw.githubusercontent.com/erlimar/Home/master/kvm.ps1' -OutFile $KVMPS
    }
    if((Test-Path $KVMCMD) -ne 1){
        Write-Host "Downloading KVM.cmd..."
        Invoke-WebRequest 'https://raw.githubusercontent.com/erlimar/Home/master/kvm.cmd' -OutFile $KVMCMD
    }
    if((Test-Path $KVM_PATH) -ne 1){
        Write-Host "Installing K's"

        Write-Host ""
        Write-Host "KRE [Net45] x86"
        Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x86 -svr50 -persistent -alias $KLRE5RDEV" #kvm use e5r
        
        Write-Host ""
        Write-Host "KRE [Core] x86"
        #Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x86 -svrc50 -alias $KLRE5RDEV-core"       #kvm use e5r-core
        
        Write-Host ""
        Write-Host "KRE [Net45] x64"
        #Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x64 -svr50 -alias $KLRE5RDEV-x64"         #kvm use e5r-x64
        
        Write-Host ""
        Write-Host "KRE [Core] x64"
        #Invoke-Expression -Command:"$KVMCMD install $KLRVERSION -x64 -svrc50 -alias $KLRE5RDEV-x64-core"   #kvm use e5r-x64-core
        
        Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x86 $KLRVERSION -x86 -svr50"                  #kvm use e5r-x86
        Invoke-Expression -Command:"$KVMCMD alias $KLRE5RDEV-x86-core $KLRVERSION -x86 -svrc50"            #kvm use e5r-x86-core

        Write-Host ""
        Write-Host "Set default [Net45 x86]"
        Invoke-Expression -Command:"$KVMCMD use $KLRE5RDEV"      #Set default [e5r]
        Invoke-Expression -Command:"$KVMCMD setup"
    }

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
    #Restore-Package "E5R.LocalDB.js.AspNet" "1.0.1"
}

Run