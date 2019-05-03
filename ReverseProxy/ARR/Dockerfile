# escape=`

FROM microsoft/iis

WORKDIR /
SHELL ["powershell","-command"]

# Download and install ARR

RUN powershell -Command Install-WindowsFeature Web-Mgmt-Service
RUN powershell -Command Install-WindowsFeature WAS-Config-APIs
RUN powershell -Command Install-WindowsFeature NET-Framework-45-ASPNET

RUN net stop was /y
RUN reg add HKLM\SOFTWARE\Microsoft\InetStp /v MajorVersion /t REG_DWORD /d 0x9 /f

RUN powershell -Command wget http://download.microsoft.com/download/5/7/0/57065640-4665-4980-a2f1-4d5940b577b0/webfarm_v1.1_amd64_en_us.msi -OutFile webfarm_v1.1_amd64_en_us.msi
RUN Start-Process msiexec.exe -ArgumentList '/i', 'webfarm_v1.1_amd64_en_us.msi', '/q' -NoNewWindow -Wait

RUN powershell -Command wget http://download.microsoft.com/download/3/4/1/3415F3F9-5698-44FE-A072-D4AF09728390/ExternalDiskCache_amd64_en-US.msi -OutFile ExternalDiskCache_amd64_en-US.msi
RUN  Start-Process msiexec.exe -ArgumentList '/i', 'ExternalDiskCache_amd64_en-US.msi', '/quiet', '/norestart' -NoNewWindow -Wait

RUN powershell -Command wget http://download.microsoft.com/download/6/7/D/67D80164-7DD0-48AF-86E3-DE7A182D6815/rewrite_amd64_en-US.msi -OutFile rewrite_amd64_en-US.msi
RUN  Start-Process msiexec.exe -ArgumentList '/i', 'rewrite_amd64_en-US.msi', '/quiet', '/norestart' -NoNewWindow -Wait

RUN powershell -Command wget http://download.microsoft.com/download/6/3/D/63D67918-483E-4507-939D-7F8C077F889E/requestRouter_x64.msi -OutFile requestRouter_x64.msi
RUN  Start-Process msiexec.exe -ArgumentList '/i', 'requestRouter_x64.msi', '/quiet', '/norestart' -NoNewWindow -Wait

RUN reg add HKLM\SOFTWARE\Microsoft\InetStp /v MajorVersion /t REG_DWORD /d 0xa /f

RUN powershell -Command restart-service was -force
RUN powershell -Command restart-service wmsvc -force

# Configure ARR reverse proxy rewrite rules for HTTP and HTTPS traffic

SHELL ["cmd", "/S", "/C" ]
RUN powershell -Command Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/proxy" -name "enabled" -value "True"
RUN powershell -Command Set-WebConfigurationProperty -pspath 'MACHINE/WEBROOT/APPHOST'  -filter "system.webServer/proxy" -name "reverseRewriteHostInResponseHeaders" -value "False"
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='ReverseProxyHttps', patternSyntax='Wildcard',stopProcessing='True']" /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='ReverseProxyHttps',patternSyntax='Wildcard',stopProcessing='True']".match.url:"*"  /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='ReverseProxyHttps',patternSyntax='Wildcard',stopProcessing='True']".action.type:"Rewrite"  /"[name='ReverseProxyHttps',patternSyntax='Wildcard',stopProcessing='True']".action.url:"https://{C:1}.container.{C:2}.{C:3}/{REQUEST_URI}"  /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='ReverseProxyHttps',patternSyntax='Wildcard',stopProcessing='True'].conditions.[input='{HTTPS}',pattern='on']" /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='ReverseProxyHttps',patternSyntax='Wildcard',stopProcessing='True'].conditions.[input='{HTTP_HOST}',pattern='*.*.*']" /commit:apphost

RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='ReverseProxyHttp', patternSyntax='Wildcard',stopProcessing='True']" /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='ReverseProxyHttp',patternSyntax='Wildcard',stopProcessing='True']".match.url:"*"  /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /"[name='ReverseProxyHttp',patternSyntax='Wildcard',stopProcessing='True']".action.type:"Rewrite"  /"[name='ReverseProxyHttp',patternSyntax='Wildcard',stopProcessing='True']".action.url:"http://{C:1}.container.{C:2}.{C:3}/{REQUEST_URI}"  /commit:apphost
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config -section:system.webServer/rewrite/globalRules /+"[name='ReverseProxyHttp',patternSyntax='Wildcard',stopProcessing='True'].conditions.[input='{HTTP_HOST}',pattern='*.*.*']" /commit:apphost

#Enable Failed Request Tracing on the Default Web Site
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set site "Default Web Site" -traceFailedRequestsLogging.enabled:"true" /commit:apphost

#Configure the Failed Request Tracing Rules
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config "Default Web Site" -section:system.webServer/tracing/traceFailedRequests /+"[path='*']"
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config "Default Web Site" -section:system.webServer/tracing/traceFailedRequests /+"[path='*'].traceAreas.[provider='WWW Server',areas='Rewrite,RequestRouting',verbosity='Verbose']"
RUN C:\\Windows\\system32\\inetsrv\\appcmd.exe set config "Default Web Site" -section:system.webServer/tracing/traceFailedRequests /[path='*'].failureDefinitions.statusCodes:"200-399"

# Create application websites in ARR container, and configure SSL certificates for end-to-end SSL

SHELL ["powershell","-command"]
RUN New-Item -ItemType Directory C:\installsite
ADD installarrwebsite.ps1 c:\installsite\
#ADD container.abcxdomain.com.pfx c:\installsite\
#ADD app01.abcxdomain.com.pfx c:\installsite\
#ADD app02.abcxdomain.com.pfx c:\installsite\
RUN c:\installsite\installarrwebsite