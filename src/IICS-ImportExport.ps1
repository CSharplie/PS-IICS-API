. $PSScriptRoot\IICS-API.ps1
. $PSScriptRoot\IICS-Objects.ps1

Function IICS-Export([Parameter(Mandatory)] $Query, [Parameter(Mandatory)] $Path, $ExportName = "Powershell Export") {
    [System.Net.ServicePointManager]::Expect100Continue = $true
    [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Write-Debug "Call IICS-Export function with parameters:"
    Write-Debug "- Query = '$Query'"
    Write-Debug "- Path = '$Path'"

    IICS-Check-Connection

    Write-Debug "Get list of objects to exports"
    $Objects = IICS-Get-Object-List $Query
    Write-Debug "$($Objects.Count) object(s) to export"
    $ObjectsIDs = $Objects | Select-Object -Property id

    $Body = @{
        name = $ExportName
        objects = $ObjectsIDs
    } | ConvertTo-Json

    Write-Debug "Start export"
    Try {
        Write-Debug "Try to call login API"

        $Headers = IICS-Get-Headers-V3
        $Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSBaseURL)/public/core/v3/export" -Method Post -Body $Body -Headers $Headers
        
        Write-Debug "Export in progress with ID :'$($Result.id)'"
        $ExportID = $Result.id
    }
    Catch [System.Net.WebException] {
        Throw IICS-Get-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }

    $ExportFinished = $False

    While($ExportFinished -eq $False) {
        Write-Debug "Wating export"
        Start-Sleep -Seconds 5
        Try{
            Write-Debug "Try to call login API"

            $Headers = IICS-Get-Headers-V3
            $Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSBaseURL)/public/core/v3/export/$ExportID" -Method Get -Headers $Headers
            
            $ExportStatus = $Result.status.state
           
            If($ExportStatus -ne "IN_PROGRESS") {
                Write-Debug "Export finished with status '$ExportStatus'"
                $ExportFinished = $True
                
                if($ExportStatus -ne "SUCCESSFUL"){
                    Return $False
                }
            }
        }
        Catch [System.Net.WebException] {
            Throw IICS-Get-HttpErrorDetail -Exception $_
        }
        Catch {
            Throw $_ 
        }
    }
    
    Write-Debug "Download package"
    Try {
        Write-Debug "Try to call login API"

        $Headers = @{ "INFA-SESSION-ID" = $Global:IICSSessionID }
        Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSBaseURL)/public/core/v3/export/$ExportID/package" -Method Get -Headers $Headers -OutFile $Path -ContentType "application/octet-stream"  > $Null
        Write-Debug "Download done"
    }
    Catch [System.Net.WebException] {
        Throw IICS-Get-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }
}
