
$HostHeader = 'container.abcxdomain.com'
$CertPassword = "pass@word222"
$Name = 'Default Web Site'
$IP = '*'

$pwd = ConvertTo-SecureString -String $CertPassword -Force -AsPlainText
ConvertTo-SecureString -String $pwd -Force -AsPlainText
Import-PfxCertificate -FilePath "c:\\installsite\\$HostHeader.pfx" -CertStoreLocation 'Cert:\LocalMachine\My' -Password $pwd -Verbose

$cert = (gci cert:\LocalMachine\My)[0]
New-WebBinding -Name $Name -Protocol 'https' -Port 443 -IPAddress $IP -HostHeader '' -SslFlags 0
$NewBinding = get-webbinding -hostheader '' -protocol https
$NewBinding.AddSSLCertificate("$($cert.getcerthashstring())","MY")