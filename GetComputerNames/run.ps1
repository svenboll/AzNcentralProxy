using namespace System.Net

# Input bindings are passed in via param block.
param($Request)

# Define the command-line parameters to be used by the script
$serverHost = $ENV:NCentralHostname
$JWT = $ENV:JWTKey
$SpecifiedCustomerID = $Request.Query.ID

# generating URL and http request body
$bindingURL = "https://" + $serverHost + "/dms2/services2/ServerEI2?wsdl"
$CustRestBody = 
@"
<soap:Envelope xmlns:soap="http://www.w3.org/2003/05/soap-envelope" xmlns:ei2="http://ei2.nobj.nable.com/">
    <soap:Header/>
    <soap:Body>
        <ei2:deviceList>
            <ei2:username>$null</ei2:username>
            <ei2:password>$JWT</ei2:password>
            <ei2:settings>
                <ei2:key>customerID</ei2:key>
                <ei2:value>$SpecifiedCustomerID</ei2:value>
            </ei2:settings>
            <ei2:settings>
                <ei2:key>devices</ei2:key>
                <ei2:value>true</ei2:value>
            </ei2:settings>
            <ei2:settings>
                <ei2:key>probes</ei2:key>
                <ei2:value>false</ei2:value>
            </ei2:settings>
        </ei2:deviceList>
    </soap:Body>
</soap:Envelope>
"@ 

# Invoke RestMethod to receive DeviceList
Try {
    $DeviceList = (Invoke-RestMethod -Uri $bindingURL -body $CustRestBody -Method POST).Envelope.body.deviceListResponse.return
}
Catch {
    Write-Host "Could not connect: $($_.Exception.Message)"
    exit
}

# Set up the "Customers" array, then populate
$Computernames = $DeviceList.Items | Where-Object { $_.key -eq "device.longname" } | Select-Object Value
$Output = $Computernames.value

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = [HttpStatusCode]::OK
        Body       = $Output
    })