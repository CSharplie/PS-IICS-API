# API Run functions 
## Run a published taskflow
### Description
Use IICS-Run-Taskflow to start a published taskflow

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|Path|Yes|Folder of your taskflow|
|Name|Yes|Name of your taskflow|
|PublishName|No|UniqueName of published taskaflow (PublishName = Name by default)|

### Result
Awating end ofthe taskflow

True if the run if successful
False if the run if fail

### Sample

    # Connect to API
    IICS-Connect -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    # Start a taskflow
    IICS-Run-Taskflow -Path "/ProjectOfMyCat/Folder/" -Name "tf_export_data" -PublishName "tf_export_data-1"

## Dependencies
* IICS-API
* IICS-Objects