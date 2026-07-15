using namespace System.Net

# Input bindings are passed in via param block.
param($Request)

# Define the command-line parameters to be used by the script
$serverHost = $ENV:NCentralHostname
$JWT = $ENV:JWTKey
$SpecifiedCustomerID = $Request.Query.ID

# Define Output Variables
$script:outerror = $null

# generating URL and http request body
$authheader = @{}
$authheader.Add("accept", "application/json")
$authheader.Add("authorization", "Bearer $($JWT)")
try {
    $authresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/auth/authenticate" -Method POST -Headers $authheader

    try {
        $deviceheader = @{} 
        $deviceheader.Add("accept", "application/json")
        $deviceheader.Add("authorization", "Bearer $($authresponse.tokens.access.token)")
        $deviceresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/devices?pageSize=-1&select=customerid%3D%3D$($SpecifiedCustomerID)%2Csiteid%3D%3D$($SpecifiedCustomerID)" -Method GET -Headers $deviceheader
    }
    catch {
        $script:outerror = $_.Exception
    }
}
catch {
    $script:outerror = $_.Exception
}

if ($script:outerror) {
    $outStatusCode = $script:outerror.StatusCode
    $outBody = $script:outerror.Message
} else {
    # Filter the items, then populate
    $Computernames = $deviceresponse.data | Where-Object { $_.isProbe -eq $false -and $_.osid -eq "winnt" } | Select-Object discoveredname

    $outStatusCode = [HttpStatusCode]::OK
    $outBody = $Computernames.discoveredname
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $outStatusCode
        Body       = $outBody
    })
