Import-Module "$ENV:ProgramFiles\Microsoft SDKs\Service Fabric\Tools\PSModule\ServiceFabricSDK\ServiceFabricSDK.psm1"

# connect to SF cluster over private IP. Replace cert thumbprint with SF cluster thumbprint. Replace IP address with cluster IP.
Connect-ServiceFabricCluster -ConnectionEndpoint 10.0.0.252:19000 `
-X509Credential -ServerCertThumbprint D2D21D8CF93FCDF6DC1E3B5D7F05B11BE2F44218 `
-FindType FindByThumbprint -FindValue D2D21D8CF93FCDF6DC1E3B5D7F05B11BE2F44218 `
-StoreLocation CurrentUser -StoreName My

# Install initial ARR app version
$path = 'C:\sfcontainers\ARR\ARR\ARR\pkg\Debug'
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $path -ApplicationPackagePathInImageStore ArrAppV1 -TimeoutSec 1800
Register-ServiceFabricApplicationType ArrAppV1  
#Get-ServiceFabricApplicationType # this just shows the registered type
New-ServiceFabricApplication -ApplicationName "fabric:/ArrSrv" -ApplicationTypeName "ARRType" -ApplicationTypeVersion "1.0.1"

# Upgrade ARR to new version
Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $path -ApplicationPackagePathInImageStore ArrAppV2 -TimeoutSec 1800
Register-ServiceFabricApplicationType ArrAppV2  
Start-ServiceFabricApplicationUpgrade -ApplicationName "fabric:/ArrSrv" -ApplicationTypeVersion "1.0.1" -Monitored -FailureAction Rollback


# Deploy/Remove applications

Function DeployApp($app)
{
    $path = "C:\sfcontainers\$app\sf$app\pkg\Debug"
    $imageStore = $app + 'v1'
    $appName = "fabric:/" + (Get-Culture).TextInfo.ToTitleCase($app) 
    $appType = 'sf' + $app + 'Type'
    Copy-ServiceFabricApplicationPackage -ApplicationPackagePath $path -ApplicationPackagePathInImageStore $imageStore -TimeoutSec 1800
    Register-ServiceFabricApplicationType $imageStore  
    New-ServiceFabricApplication $appName $appType 1.0.0    # fabric:/App01 can be anything. sfapp01Type comes from the ApplicationManifest ApplicationTypeName="xxx"
}

DeployApp('app01')
DeployApp('app02')

Get-ServiceFabricApplicationType  # this just shows the registered type

Remove-ServiceFabricApplication  fabric:/ArrSrv -Force
Remove-ServiceFabricApplication  fabric:/App01 -Force
Remove-ServiceFabricApplication  fabric:/App02 -Force
Unregister-ServiceFabricApplicationType ARRType 1.0.0 -Force
Unregister-ServiceFabricApplicationType sfapp01Type 1.0.0 -Force
Unregister-ServiceFabricApplicationType sfapp02Type 1.0.0 -Force