# install the container cert in the ARR container
$pwd = ConvertTo-SecureString -String "pass@word222" -Force -AsPlainText

#----------------------------------------------------------------------------------------------------------
# add app websites to IIS in ARR's container

Function AddWebsite($Name)
{
    $HostHeader = "$Name.acnsfc.com"
    $pwd = ConvertTo-SecureString -String "pass@word222" -Force -AsPlainText
    
    C:\Windows\System32\inetsrv\appcmd.exe add site /name:$Name /physicalPath:"c:/inetpub/$Name" /bindings:http/*:80:$HostHeader
}

AddWebsite('eshop')
AddWebsite('eshop2')
