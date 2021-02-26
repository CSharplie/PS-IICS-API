# API Export functions 
## Export IICS zip package
### Description
Use IICS-Export function to export a zip file.

### Parameters :
|Name|Mandatory|Description|
|---|---|---|
|Query|Yes|Query to select objects from IICS. See [Informatica API reference](https://docs.informatica.com/integration-cloud/cloud-platform/current-version/rest-api-reference/platform-rest-api-version-3-resources/objects.html) |
|Path|Yes|Target file name|

### Sample :

    # Connect to API
    IICS-Connect -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    $ExportResult = IICS-Export -Query "type=='MTT'" -Path "C:\Exports\my_iics_export.zip"
    If($ExportResult) {
        Write-Host "Yay!"
    }
    Else {
        Write-Host "It's not working :("
    }

## Dependencies
* IICS-API
* IICS-Objects