. $PSScriptRoot\IICS-API.ps1
. $PSScriptRoot\IICS-Objects.ps1

Function IICS-Run-Taskflow ([Parameter(Mandatory)] $Path, [Parameter(Mandatory)] $Name, $PublishName) {
    [System.Net.ServicePointManager]::Expect100Continue = $true
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Write-Debug "Call IICS-Run-Taskflow function with parameters:"
    Write-Debug "- Path = '$Path'"
    Write-Debug "- Name = '$Name'"
    Write-Debug "- PublishName = '$PublishName'"

    IICS-Check-Connection

    if($Path.EndsWith("/")){
        $Path = $Path.Remove($Path.Length - 1)
    }
    if($Path.StartsWith("/")){
        $Path = $Path.substring(1)
    }

    if($Null -eq $PublishName){
        $PublishName = $Name
    }


    $Query = "type==TASKFLOW and location==$Path"
    Write-Debug "Get objects with quey Query $Query"

    $Objects = IICS-Get-Object-List -Query $Query
    $Taskflow = $Objects | Where-Object { $_.path -eq "$Path/$Name" }

    If($Null -eq $Taskflow){
        throw "$Path/$Name taskflow do not exists"
    }

    If($Taskflow.customAttributes.publicationStatus -ne "published"){
        throw "$Path/$Name is not published"
    }

    $RunID = $Null
	try {
        $Headers = IICS-Get-Headers-V3
		$Result = Invoke-RestMethod -Proxy $Proxy -Uri "$($Global:IICSRunBaseUrl)/active-bpel/rt/$PublishName" -Method GET -Headers $Headers
		$RunID = $Result.RunId
		Write-Debug "Started with RunID '$RunID'"
	}
    Catch [System.Net.WebException] {
        Throw IICS-Get-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }

	while($True) {
		try {
			Start-Sleep -Seconds 10
            $Headers = IICS-Get-Headers-V3
			$Result = Invoke-RestMethod -Proxy $Proxy -Uri "$($Global:IICSRunBaseUrl)/active-bpel/services/tf/status/$RunID" -Method GET -Headers $Headers
			If($Result.Status -ne "RUNNING") {
				if($Result.Status -eq "SUCCESS"){
					Write-Debug "Job done successfully"
					Return $True
				}
				Else {
					Write-Debug "Job done with error"
					Return $False
				}
			}
			else {
				Write-Debug "Waiting job ending"
			}
		}
        Catch [System.Net.WebException] {
            Throw IICS-Get-HttpErrorDetail -Exception $_
        }
        Catch {
            Throw $_ 
        }
	}

}