// Use this file to write queries to test your data connector
let
    result = PowerPlatformAPI.Contents("https://api.bap.microsoft.com/providers/Microsoft.BusinessAppPlatform/scopes/admin/environments?api-version=2020-10-01&$expand=properties.capacity,properties.addons")
in
    result