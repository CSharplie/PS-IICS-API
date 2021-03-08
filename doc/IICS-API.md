# API Core functions 
## Connect to API
### Description
Use Connect-IICS-API to connect to the IICS API

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|ConnectBaseURL|Yes|Url to connect to API|
|UserName|No|Username|
|Password|No|Password|
|Proxy|No|Proxy used to connect. Default: null|

### Sample

    # Connect to API
    Connect-IICS-API -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"
