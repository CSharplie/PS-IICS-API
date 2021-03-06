. $PSScriptRoot\IICS-API.ps1

Function Get-IICS-Objects ([Parameter(Mandatory)] $Query, $Limit = 0, $Skip = 0, $Page = 1) {
    [System.Net.ServicePointManager]::Expect100Continue = $true
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    $ErrorActionPreference = "Stop"
    
    Write-Debug "Call Get-IICS-Objects function with parameters:"
    Write-Debug "- Query = '$Query'"
    Write-Debug "- Limit = '$Limit'"
    Write-Debug "- Skip = '$Skip'"
    Write-Debug "- Page = '$Page'"
    $Result = $Null

    Confirm-IICS-Connection

    Try {
        $QueryLimit = $Limit
        If($Limit -eq 0) {
            Write-Debug "Limit changed to 200"
            $QueryLimit = 200
        }

        Write-Debug "Try to call login API"
        $Headers = Get-IICS-Headers-V3
        $Objects = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSBaseURL)/public/core/v3/objects?q=$Query&limit=$QueryLimit&skip=$Skip" -Method GET -Headers $Headers
        
        if($Null -eq $Objects.objects) {
            Write-Debug "No objects found"
            Return @()
        }
        Write-Debug "$($Objects.objects.Count) object(s) founds"
        $Result = $Objects.objects 
    }
    Catch [System.Net.WebException] {
        Throw Get-IICS-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }

    If($Limit -eq 0 -and $Objects.objects.Count -eq 200){
        Write-Debug "Recall API to get others results"
        $NewSkip =  $Page * 200
        $NewPage = $Page + 1
        $Result += Get-IICS-Objects -Query $Query -Limit 0 -Skip $NewSkip -Page $NewPage
    }

    Return $Result
}

