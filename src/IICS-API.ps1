Function Get-IICS-HttpErrorDetail([Parameter(Mandatory)] $Exception) {
    $ErrorActionPreference = "Stop"
    
    Try {
        $Response = $Exception.Exception.Response

        $Steam = $Response.GetResponseStream()
        $StreamReader = New-Object System.IO.StreamReader $Steam
        $Body = $StreamReader.ReadToEnd()
    
        $ErrorData = (ConvertFrom-Json $Body)
        Return "$($_.Exception.Response.StatusCode) : $($ErrorData.Error.Message)"
    }
    Catch {
        $Response = $Exception.Exception.Response

        $Steam = $Response.GetResponseStream()
        $StreamReader = New-Object System.IO.StreamReader $Steam
        $Body = $StreamReader.ReadToEnd()

        Return $Body
    }
}

Function Get-IICS-Headers-V1() {
    $ErrorActionPreference = "Stop"
    
    Return @{
        "IDS-SESSION-ID" = $Global:IICSSessionID
        "Content-Type" = "application/json;charset=UTF-8"
        "Accept" = "application/json"
    }
}
Function Get-IICS-Headers-V2() {
    $ErrorActionPreference = "Stop"

    Return @{
        "icSessionId" = $Global:IICSSessionID
        "Content-Type" = "application/json;charset=UTF-8"
        "Accept" = "application/json"
    }
}

Function Get-IICS-Headers-V3() {
    $ErrorActionPreference = "Stop"

    Return @{
        "Content-Type" = "application/json;charset=UTF-8"
        "INFA-SESSION-ID" = $Global:IICSSessionID
        "Accept" = "application/json"
    }
}


Function Confirm-IICS-Connection() {
    $ErrorActionPreference = "Stop"

    If($Null -eq $Global:IICSSessionID) {
        Throw "Not connected to API. Please use Connect-IICS-API function"
    }
}

Function Connect-IICS-API ([Parameter(Mandatory)] $ConnectBaseURL, [Parameter(Mandatory)] $UserName, [Parameter(Mandatory)] [SecureString] $Password, $Proxy) {
    [System.Net.ServicePointManager]::Expect100Continue = $true
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    $ErrorActionPreference = "Stop"

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($Password);  
    $LoginPassword = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)

    Write-Debug "Call Connect-IICS-API function with parameters:"
    Write-Debug "- ConnectBaseURL = '$ConnectBaseURL'"
    Write-Debug "- UserName = '$UserName'"
    Write-Debug "- Password = '******'"
    Write-Debug "- Proxy = '$Proxy'"

    $Headers = @{ "Content-Type" = "application/json;charset=UTF-8" }

    $Body = @{
        username = $Username
        password = $LoginPassword
    } | ConvertTo-Json

    Try {
        Write-Debug "Try to call login API"
        $Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$ConnectBaseURL/saas/public/core/v3/login" -Method Post -Body $Body -Headers $Headers

        $Global:IICSSessionID = $Result.userInfo.sessionId
        $Global:IICSBaseURL = $Result.products.baseApiUrl
        $Global:IICSRunBaseUrl = $Result.products.baseApiUrl -replace "/saas", $null
        $Global:IICSProxy = $Proxy

        Write-Debug "Set global variables:"
        Write-Debug "- Global:IICSSessionID = '$($Global:IICSSessionID)'"
        Write-Debug "- Global:IICSBaseURL = '$($Global:IICSBaseURL)'"
        Write-Debug "- Global:IICSRunBaseUrl = '$($Global:IICSRunBaseUrl)'"
        Write-Debug "- Global:IICSProxy = '$Global:IICSProxy'"
    }
    Catch [System.Net.WebException] {
        Throw Get-IICS-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }
}