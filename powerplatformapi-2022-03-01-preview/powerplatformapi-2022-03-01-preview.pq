[Version = "1.0.0"]
section powerplatformapi;

authorizeUri    = "https://login.windows.net/common/oauth2/authorize";
BaseUrl         = "https://api.powerplatform.com/";
envAPIversion   = "2022-03-01-preview";

DefaultRequestHeaders = [
    #"Accept" = "application/json;odata.metadata=minimal",
    #"OData-MaxVersion" = "4.0"
];

// Set API pages as list
// envFunctions = {
//     "applicationPackages"
// };

[DataSource.Kind="powerplatformapi", Publish="powerplatformapi.Publish"]
shared PowerPlatformAPI.Contents =  Value.ReplaceType(powerplatformapiNavTable, type function (envGUID as Text.Type) as any);

powerplatformapiNavTable = (envGUID as text) as table =>
    let
        source = #table({"Name", "Data", "ItemKind", "ItemName", "IsLeaf"}, {
            { "Environment - Application Packages", powerplatformapi.Feed(BaseUrl & "appmanagement/environments/" & envGUID & "/applicationPackages" & "?api-version=" & envAPIversion), "Table", "Table", true }
        }),
        navTable = Table.ToNavigationTable(source, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
    in
        navTable;

// Autocreate navigation table from API pages list "envFunctions"
// powerplatformapiNavTable = (envGUID as text) as table =>
//     let
//         entitiesAsTable = Table.FromList(envFunctions, Splitter.SplitByNothing()),
//         rename = Table.RenameColumns(entitiesAsTable, {{"Column1", "Name"}}),
//         // Add Data as a calculated column
//         withData = Table.AddColumn(rename, "Data", each powerplatformapi.Feed(BaseUrl & "appmanagement/environments/" & envGUID & "/applicationPackages" & "?api-version=" & envAPIversion), Uri.Type),
//         // Add ItemKind and ItemName as fixed text values
//         withItemKind = Table.AddColumn(withData, "ItemKind", each "Table", type text),
//         withItemName = Table.AddColumn(withItemKind, "ItemName", each "Table", type text),
//         // Indicate that the node should not be expandable
//         withIsLeaf = Table.AddColumn(withItemName, "IsLeaf", each true, type logical),
//         // Generate the nav table
//         navTable = Table.ToNavigationTable(withIsLeaf, {"Name"}, "Name", "Data", "ItemKind", "ItemName", "IsLeaf")
//     in
//         navTable;

Table.ToNavigationTable = (
    table as table,
    keyColumns as list,
    nameColumn as text,
    dataColumn as text,
    itemKindColumn as text,
    itemNameColumn as text,
    isLeafColumn as text
) as table =>
    let
        tableType = Value.Type(table),
        newTableType = Type.AddTableKey(tableType, keyColumns, true) meta 
        [
            NavigationTable.NameColumn = nameColumn, 
            NavigationTable.DataColumn = dataColumn,
            NavigationTable.ItemKindColumn = itemKindColumn, 
            Preview.DelayColumn = itemNameColumn, 
            NavigationTable.IsLeafColumn = isLeafColumn
        ],
        navigationTable = Value.ReplaceType(table, newTableType)
    in
        navigationTable;

powerplatformapi.Feed = (BaseUrl as text) =>
    let
        Source = Json.Document(Web.Contents(BaseUrl, [ Headers = DefaultRequestHeaders ]))[value],
        Result = Table.FromRecords(Source)
    in
        Result;

powerplatformapi = [
        TestConnection = (dataSourcePath) => { "PowerPlatformAPI.Contents" },
        Authentication = [
            Aad = [AuthorizationUri = authorizeUri, Resource = Text.RemoveRange(BaseUrl,Text.Length(BaseUrl)-1)]
    ],
    Label = "Power Platform API, version: 2022-03-01-preview"
];

powerplatformapi.Publish = [
    Beta = true,
    Category = "Power Platform",
    ButtonText = { Extension.LoadString("ButtonTitle"), Extension.LoadString("ButtonHelp") },
    LearnMoreUrl = "https://learn.microsoft.com/en-us/rest/api/power-platform/appmanagement/applications/get-environment-application-package",
    SourceImage = powerplatformapi.Icons,
    SourceTypeImage = powerplatformapi.Icons
];

powerplatformapi.Icons = [
    Icon16 = { Extension.Contents("powerplatformapi16.png"), Extension.Contents("powerplatformapi20.png"), Extension.Contents("powerplatformapi24.png"), Extension.Contents("powerplatformapi32.png") },
    Icon32 = { Extension.Contents("powerplatformapi32.png"), Extension.Contents("powerplatformapi40.png"), Extension.Contents("powerplatformapi48.png"), Extension.Contents("powerplatformapi64.png") }
];