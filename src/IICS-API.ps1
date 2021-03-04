Function IICS-Get-HttpErrorDetail([Parameter(Mandatory)] $Exception) {
    Try {
        $Response = $Exception.Exception.Response

        $Steam = $Response.GetResponseStream()
        $StreamReader = New-Object System.IO.StreamReader $Steam
        $Body = $StreamReader.ReadToEnd()
    
        $ErrorData = (ConvertFrom-Json $Body)
        Return $ErrorData.Error.Message
    }
    Catch {
        $Response = $Exception.Exception.Response

        $Steam = $Response.GetResponseStream()
        $StreamReader = New-Object System.IO.StreamReader $Steam
        $Body = $StreamReader.ReadToEnd()

        Return $Body
    }
}

Function IICS-Get-Headers-V3() {
    Return @{
        "Content-Type" = "application/json;charset=UTF-8"
        "INFA-SESSION-ID" = $Global:IICSSessionID
        "Accept" = "application/json"
    }
}

Function IICS-Check-Connection() {
    If($Null -eq $Global:IICSSessionID) {
        Throw "Not connected to API. Please use IICS-Connect function"
    }
}

Function IICS-Connect ([Parameter(Mandatory)] $ConnectBaseURL, [Parameter(Mandatory)] $UserName, [Parameter(Mandatory)] $Password, $Proxy) {
	[System.Net.ServicePointManager]::Expect100Continue = $true
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Write-Debug "Call IICS-Connect function with parameters:"
    Write-Debug "- ConnectBaseURL = '$ConnectBaseURL'"
    Write-Debug "- UserName = '$UserName'"
    Write-Debug "- Password = '******'"
    Write-Debug "- Proxy = '$Proxy'"

    $Headers = @{ "Content-Type" = "application/json;charset=UTF-8" }

    $Body = @{
        username = $Username
        password = $Password
    } | ConvertTo-Json

    Try {
        Write-Debug "Try to call login API"
        $Result = Invoke-RestMethod -Proxy $Config.Proxy -Uri "$ConnectBaseURL/saas/public/core/v3/login" -Method Post -Body $Body -Headers $Headers

        Write-Debug "Set global variables:"
        Write-Debug "- Global:IICSSessionID = '$($Result.userInfo.sessionId)'"
        Write-Debug "- Global:IICSBaseURL = '$($Result.products.baseApiUrl)'"
        Write-Debug "- Global:IICSProxy = '$Proxy'"

        $Global:IICSSessionID = $Result.userInfo.sessionId
        $Global:IICSBaseURL = $Result.products.baseApiUrl
        $Global:IICSRunBaseUrl = $Result.products.baseApiUrl -replace "/saas", $null
        $Global:IICSProxy = $Proxy
    }
    Catch [System.Net.WebException] {
        Throw IICS-Get-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }
}