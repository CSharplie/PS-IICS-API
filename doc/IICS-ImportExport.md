# API Export functions 
## Export IICS zip package
### Description
Use Export-IICS-Package function to export a zip file.

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|Query|Yes|Query to select objects from IICS. See [Informatica API reference](https://docs.informatica.com/integration-cloud/cloud-platform/current-version/rest-api-reference/platform-rest-api-version-3-resources/objects.html) |
|Path|Yes|Target file name|

### Sample

    # Connect to API
    Connect-IICS-API -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    $ExportResult = Export-IICS-Package -Query "type=='MTT'" -FilePath "C:\Exports\my_iics_export.zip"
    If($ExportResult) {
        Write-Host "Yay!"
    }
    Else {
        Write-Host "It's not working :("
    }

## Dependencies
* IICS-API
* IICS-Objects