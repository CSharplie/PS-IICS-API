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

## Run a mass ingestion task
### Description
Use IICS-Run-MassIngestion to start a mass ingestion task

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
    IICS-Connect -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"

    # Start a mass ingestion
    IICS-Run-MassIngestion -Path "/ProjectOfMyCat/Folder/" -Name "mi_import_data"

## Dependencies
* IICS-API
* IICS-Objects