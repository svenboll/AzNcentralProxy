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
        $customerheader = @{}
        $customerheader.Add("accept", "application/json")
        $customerheader.Add("authorization", "Bearer $($authresponse.tokens.access.token)")
        $customerresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/customers/$($SpecifiedCustomerID)/registration-token" -Method GET -Headers $customerheader
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
    $outStatusCode = [HttpStatusCode]::OK
    $outBody = $customerresponse.data.registrationToken
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $outStatusCode
        Body       = $outBody
    })
