# API Object functions 
## Get list of objects
### Description
Use IICS-Get-Object-List to get a list of objects with all details

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|Query|Yes|Query to select objects from IICS. See [Informatica API reference](https://docs.informatica.com/integration-cloud/cloud-platform/current-version/rest-api-reference/platform-rest-api-version-3-resources/objects.html) |
|Limit|No|Number of object to list. Use 0 to get full list|
|Skip|No|Number of object to skip|

### Result
|Name|Type|Description|
|---|---|---|
|id|String|ID of the object|
|path|String|Full path of the object|
|type|String|Type of the object|
|description|String|Description of the object|
|updatedBy|String|Last username to update the object|
|updateTime|DateTime|Last time to update the object|
|tags|Array||
|sourceControl|String||
|customAttributes|String||

### Sample

    # Connect to API
    IICS-Connect -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    # Get a list of mapping task
    IICS-Get-Object-List -Query "type=='MTT'" | ForEach-Object {
        Write-Host "$($_.id) is updated from $($_.updateTime)"
    }





## Dependencies
* IICS-API