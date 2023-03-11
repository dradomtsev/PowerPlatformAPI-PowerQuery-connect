// Use this file to write queries to test your data connector
let
    result = PowerPlatformAPI.Contents("https://api.powerplatform.com/appmanagement/environments/272bb3d1-5523-e19c-994c-1353eeb6865a/applicationPackages?api-version=2022-03-01-preview")
in
    result