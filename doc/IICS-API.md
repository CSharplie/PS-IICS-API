# API Core functions 
## Connect to API
### Description
Use IICS-Connect to connect to the IICS API

### Parameters
|Name|Mandatory|Description|
|---|---|---|
|ConnectBaseURL|Yes|Url to connect to API|
|UserName|No|Username|
|Password|No|Password|
|Proxy|No|Proxy used to connect. Default: null|

### Sample

    # Connect to API
    IICS-Connect -ConnectBaseURL "https://dm-em.informaticacloud.com" -UserName "PixelCat" -Password "MiaouMiaou"
