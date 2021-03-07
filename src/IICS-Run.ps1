. $PSScriptRoot\IICS-API.ps1
. $PSScriptRoot\IICS-Objects.ps1

Function IICS-Get-Run-Object([Parameter(Mandatory)] $Path, [Parameter(Mandatory)] $Name, [Parameter(Mandatory)] $ObjectType) {
    if($Path.EndsWith("/")){
        $Path = $Path.Remove($Path.Length - 1)
    }
    if($Path.StartsWith("/")){
        $Path = $Path.substring(1)
    }

    if($Null -eq $PublishName){
        $PublishName = $Name
    }

    $Query = "type==$ObjectType and location==$Path"
    Write-Debug "Get objects with quey Query $Query"

    $Objects = IICS-Get-Object-List -Query $Query
    Return $Objects | Where-Object { $_.path -eq "$Path/$Name" }
}

Function IICS-Run-Taskflow ([Parameter(Mandatory)] $Path, [Parameter(Mandatory)] $Name, $PublishName) {
    [System.Net.ServicePointManager]::Expect100Continue = $true
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Write-Debug "Call IICS-Run-Taskflow function with parameters:"
    Write-Debug "- Path = '$Path'"
    Write-Debug "- Name = '$Name'"
    Write-Debug "- PublishName = '$PublishName'"

    IICS-Check-Connection

    $Object = IICS-Get-Run-Object -Path $Path -Name $Name
    $Taskflow = IICS-Get-Run-Object -Path $Path -Name $Name -ObjectType "TASKFLOW"

    If($Null -eq $Taskflow){
        throw "$Path/$Name taskflow do not exists"
    }

    If($Taskflow.customAttributes.publicationStatus -ne "published"){
        throw "$Path/$Name is not published"
    }

    $RunID = $Null
	try {
        $Headers = IICS-Get-Headers-V3
		$Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSRunBaseUrl)/active-bpel/rt/$PublishName" -Method GET -Headers $Headers
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
			$Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSRunBaseUrl)/active-bpel/services/tf/status/$RunID" -Method GET -Headers $Headers
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

Function IICS-Run-MassIngestion ([Parameter(Mandatory)] $Path, [Parameter(Mandatory)] $Name) {
    [System.Net.ServicePointManager]::Expect100Continue = $true
	[System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12;
    Write-Debug "Call IICS-Run-MassIngestion function with parameters:"
    Write-Debug "- Path = '$Path'"
    Write-Debug "- Name = '$Name'"

    IICS-Check-Connection

    $MassIngestion = IICS-Get-Run-Object -Path $Path -Name $Name -ObjectType "MI_TASK" 
  
    If($Null -eq $MassIngestion){
        throw "$Path/$Name mass ingestion do not exists"
    }

    Write-Debug "Object found with ID '$($MassIngestion.id)'"

    $RunID = $Null
	try {
        Write-Debug "Start mass ingestion job"
        $Headers = IICS-Get-Headers-V1
        $Body = "{`"taskId`":`"$($MassIngestion.id)`"}"
		$Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSRunBaseUrl)/mftsaas/api/v1/job" -Method Post -Headers $Headers -Body $Body
        
        $RunID = $Result.RunId
		Write-Debug "Started with RunID '$RunID'"
	}
    Catch [System.Net.WebException] {
        Throw IICS-Get-HttpErrorDetail -Exception $_
    }
    Catch {
        Throw $_ 
    }

	While($True) {
		Try {
			Start-Sleep -Seconds 10
			$Result = Invoke-RestMethod -Proxy $Global:IICSProxy -Uri "$($Global:IICSRunBaseUrl)/mftsaas/api/v1/job/$RunID/status" -Method GET -Headers $Headers
			
            If($Result.jobStatus -eq "SUCCESS") {
                Write-Debug "The Mass Tngestion task is done"
                Return $true
            }
            ElseIf($Result.jobStatus -ne "RUNNING") {
                Write-Debug "The Mass Tngestion task is fail"
				Return $False
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