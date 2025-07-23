# AzNcentralProxy #

This is a proxy to allow users to access data from a N-Able N-Central Installation without having complete API access or exposing login information like username/password or JWT (JSON Web Token) in every script.

# How to install #

Download bicep template from https://github.com/svenboll/AzureDeployments

Fill in your information:

*BaseName:* anything you want, will be appended with 5 random characters.

*JWTKey:* your N-Central JWT key. You can find this at the User management page, last tab called "API".

*NCentralHostname:* your N-Central hostname.

After creating the function, click on "Go to resource" then click on "Functions".
The available Functions should now be listed, click on one name, then on "Get Function URL".

## GetComputerNames ##

This function gets a list of all Computernames registered with the specified Customer ID.

With the function URL you can use PowerShell to retrieve the list of Computernames easily:

    $CustID = "101"
    Invoke-RestMethod -Uri "https://azncentralproxy1234.azurewebsites.net/api/GetComputerNames?code=SOMELONGCODEHERE&ID=$($CustID)"

## GetRegistrationToken ##

This function gets the RegistrationToken for the specified Customer ID to add new N-Central Agent Installations.

With the function URL you can use PowerShell to retrieve the Installation ID easily:

    $CustID = "101"
    Invoke-RestMethod -Uri "https://azncentralproxy1234.azurewebsites.net/api/GetRegistrationToken?code=SOMELONGCODEHERE&ID=$($CustID)"
