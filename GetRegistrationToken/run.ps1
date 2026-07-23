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

    $customerheader = @{}
    $customerheader.Add("accept", "application/json")
    $customerheader.Add("authorization", "Bearer $($authresponse.tokens.access.token)")
    try {        
        $customerresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/customers?select=customerId%3D%3D$($SpecifiedCustomerID)" -Method GET -Headers $customerheader
        if ($customerresponse.itemCount -eq 1) {
            $registrationresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/customers/$($SpecifiedCustomerID)/registration-token" -Method GET -Headers $customerheader
        } else {
            try {
                $customerresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/sites?select=siteId%3D%3D$($SpecifiedCustomerID)" -Method GET -Headers $customerheader
                if ($customerresponse.itemCount -eq 1) {
                    $registrationresponse = Invoke-RestMethod -Uri "https://$($serverHost)/api/sites/$($SpecifiedCustomerID)/registration-token" -Method GET -Headers $customerheader
                }
            }
            catch {
                $script:outerror = "Site Error: $($_.Exception)"
            }
        }
    }
    catch {
        $script:outerror = "Customer Error: $($_.Exception)"
    }
}
catch {
    $script:outerror = "Authentication Error: $($_.Exception)"
}

if ($script:outerror) {
    $outStatusCode = $script:outerror.StatusCode
    $outBody = $script:outerror.Message
} elseif ($registrationresponse) {
    $outStatusCode = [HttpStatusCode]::OK
    $outBody = $registrationresponse.data.registrationToken
} else {
    $outStatusCode = [HttpStatusCode]::NotFound
    $outBody = "No Customer or Site with specified ID found"
}

# Associate values to output bindings by calling 'Push-OutputBinding'.
Push-OutputBinding -Name Response -Value ([HttpResponseContext]@{
        StatusCode = $outStatusCode
        Body       = $outBody
    })
