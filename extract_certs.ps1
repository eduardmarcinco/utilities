param (
    [Parameter(Mandatory=$true)][string]$hostname,
    [Parameter(Mandatory=$true)][string]$port
)

$url = "https://${hostname}:${port}"

$WebRequest = [Net.WebRequest]::CreateHttp($url)
$WebRequest.AllowAutoRedirect = $true
$chain = New-Object -TypeName System.Security.Cryptography.X509Certificates.X509Chain
[Net.ServicePointManager]::ServerCertificateValidationCallback = {$true}

#Request website
try {
    $Response = $WebRequest.GetResponse()
}
catch {}

#Creates Certificate
$Certificate = $WebRequest.ServicePoint.Certificate.Handle
$Issuer = $WebRequest.ServicePoint.Certificate.Issuer
$Subject = $WebRequest.ServicePoint.Certificate.Subject

#Build chain
$chain.Build($Certificate)
write-host $chain.ChainElements.Count
# write-host $chain.ChainElements[0].Certificate

for($i = 1; $i -le $chain.ChainElements.Count; $i++)
{
    $o = $i - 1
    $c = $chain.ChainElements[$o].Certificate

    $content = @(
        '-----BEGIN CERTIFICATE-----'
        [System.Convert]::ToBase64String($c.RawData, 'InsertLineBreaks')
        '-----END CERTIFICATE-----'
    )

    $content | Out-File -FilePath "${hostname}_${port}_${i}.pem" -Encoding ascii
}

[Net.ServicePointManager]::ServerCertificateValidationCallback = $null
