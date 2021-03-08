# API Run functions 
## Run a published taskflow
### Description
Use Start-IICS-Taskflow-Job to start a published taskflow

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
    Connect-IICS-API -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    # Start a taskflow
    Start-IICS-Taskflow-Job -Path "/ProjectOfMyCat/Folder/" -Name "tf_export_data" -PublishName "tf_export_data-1"

## Run a mass ingestion task
### Description
Use Start-IICS-MassIngestion-Job to start a mass ingestion task

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|Path|Yes|Folder of your mass ingestion|
|Name|Yes|Name of your ingestion|

### Result
Awating end of the mass ingestion

True if the run if successful
False if the run if fail

### Sample

    # Connect to API
    Connect-IICS-API -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    # Start a mass ingestion
    Start-IICS-MassIngestion-Job -Path "/ProjectOfMyCat/Folder/" -Name "mi_import_data"

## Dependencies
* IICS-API
* IICS-Objects