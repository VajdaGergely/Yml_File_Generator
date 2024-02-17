# Info

# This tool is reading records from yml finding database and can do the followings
# * Prints finding template contents
# * Can search template by id and substrings
# * Generates yml files from database record


# Example Usage

#PS C:\> Import-Module .\web_report_tool.ps1
#PS C:\> Init
#PS C:\> Get-Help
#PS C:\> Get-ColumnNames
#PS C:\> Get-AllFinding
#PS C:\> Get-FindingById -Id 1
#PS C:\> Get-YmlOutputById -Id 2
#PS C:\> Get-YmlOutputById -Id 2 -OutFile .\output.yml
#PS C:\> Get-FindingByName -Name macro
#PS C:\> Get-FindingByContent -Content cross
#PS C:\> Get-IdByName -Name macro
#PS C:\> Get-IdByContent -Content cert


function Get-Help {
    Write-Host "Available commands:"
    Write-Host "    Get-Help                                      : Print this help menu."
    Write-Host "    Init                                          : Set ExecutionPolicy and import dll files. Needed for other commands!"
    Write-Host ""
    Write-Host "    Get-ColumnNames                               : Print the column names of findings table."
    Write-Host "    Get-AllFinding                                : Print all the content of findings table."
    Write-Host ""
    Write-Host "    Get-FindingById -Id <id>                      : Print one finding data by it's id."
    Write-Host "    Get-YmlOutputById -Id <id>                    : Print one finding data formatted in yml layout by it's id."
    Write-Host "    Get-YmlOutputById -Id <id> -OutFile <file>    : Print one finding data formatted in yml layout by it's id. And saves it to the file specified too."
    Write-Host ""
    Write-Host "    Get-FindingByName -Name <substr>              : Print all findings data that's finding name or file name matches to the given substring."
    Write-Host "    Get-FindingByContent -Content <substr>        : Print all findings data that's any field matches to the given substring."
    Write-Host ""
    Write-Host "    Get-IdByName -Name <substr>                   : Print finding ids that's finding name or file name matches to the given substring."
    Write-Host "    Get-IdByContent -Content <substr>             : Print finding ids that's any field matches to the given substring."
}

function Init {
    #Clear-Host
    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass
    Unblock-File "C:\Users\gvajda\Documents\WebYmlFileRepo\ps_test_script\System.Data.SQLite.dll"
    Unblock-File "C:\Users\gvajda\Documents\WebYmlFileRepo\ps_test_script\SQLite.Interop.dll"
    [Reflection.Assembly]::LoadFile("C:\Users\gvajda\Documents\WebYmlFileRepo\ps_test_script\System.Data.SQLite.dll")
    #Clear-Host
    Write-Output "`n[+] Init Done!"
    Write-Output "`nRun 'Get-Help' to check available commands!"
}

function Get-ColumnNames {
    # Connect to db
    $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
    $conStr = "Data Source=$dbPath"
    $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
    $sqlCon.ConnectionString = $conStr
    $sqlCon.Open()

    # Query data from db
    $cmd = $sqlCon.CreateCommand()
    $cmd.CommandText = "SELECT * FROM findings"
    $cmd.CommandType = [System.Data.CommandType]::Text
    $reader = $cmd.ExecuteReader()

    # print column names
    Write-Output "[Columns of table]"
    $reader.GetValues()
    Write-Output ""

    # Close connection
    $reader.Close()
    $sqlCon.Close()
}

function Get-AllFinding {
    # Connect to db
    $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
    $conStr = "Data Source=$dbPath"
    $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
    $sqlCon.ConnectionString = $conStr
    $sqlCon.Open()

    # Query data from db
    $cmd = $sqlCon.CreateCommand()
    $cmd.CommandText = "SELECT * FROM findings"
    $cmd.CommandType = [System.Data.CommandType]::Text
    $reader = $cmd.ExecuteReader()

    # print rows
    Write-Output "[rows]`n"
    $RecordCount = 0
    while ($reader.HasRows)
    {
        if($reader.Read())
        {
            "[id: " + $reader["id"] + "]"
            "[file_name: " + $reader["file_name"] + "]"
            Write-Output "--------"
            "rating: """ + $reader["rating"] + """"
            "name: """ + $reader["name"] + """"
            Write-Output ""
            "cvss_score: """ + $reader["cvss_score"] + """"
            "cvss_vector: """ + $reader["cvss_vector"] + """"
            "cwe: """ + $reader["cwe"] + """"
            "`nobservation: |`n" + $reader["observation"]
            "`nrisk: |`n" + $reader["risk"]
            "`nrecommendation: |`n" + $reader["recommendation"]
            $RecordCount++
            Write-Output "`n---------------------------------------------------------`n"
        }
    }
    Write-Output "`nTotal count of records: $($RecordCount)"
    Write-Output "`n---------------------------------------------------------`n"

    # Close connection
    $reader.Close()
    $sqlCon.Close()
}

function Get-FindingById {
    param (
        [string]$Id
    )

    if($Id -eq "") {
        Write-Output "Missing Id parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE id=@Id"
        $cmd.Parameters.AddWithValue("@Id", $Id) > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                "[id: " + $reader["id"] + "]"
                "[file_name: " + $reader["file_name"] + "]"
                Write-Output "--------"
                "rating: """ + $reader["rating"] + """"
                "name: """ + $reader["name"] + """"
                Write-Output ""
                "cvss_score: """ + $reader["cvss_score"] + """"
                "cvss_vector: """ + $reader["cvss_vector"] + """"
                "cwe: """ + $reader["cwe"] + """"
                "`nobservation: |`n" + $reader["observation"]
                "`nrisk: |`n" + $reader["risk"]
                "`nrecommendation: |`n" + $reader["recommendation"]
                Write-Output "`n---------------------------------------------------------`n"
            }
        }

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}

# Print all things in the yml file format (we can redirect it to a file if we want to save it in a file)
function Get-YmlOutputById {
    param (
        [Parameter(Mandatory=$true)][string]$Id,
        [Parameter(Mandatory=$false)][string]$OutFile
    )

    if($Id -eq "") {
        Write-Output "Missing Id parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE id=@Id"
        $cmd.Parameters.AddWithValue("@Id", $Id) > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                # Print to screen
                "[id: " + $reader["id"] + "]"
                "[file_name: " + $reader["file_name"] + "]"
                Write-Output "--------"
                "rating: """ + $reader["rating"] + """"
                "name: """ + $reader["name"] + """"
                Write-Output ""
                "cvss_score: """ + $reader["cvss_score"] + """"
                "cvss_vector: """ + $reader["cvss_vector"] + """"
                "cwe: """ + $reader["cwe"] + """"
                "`nobservation: |`n" + $reader["observation"]
                "`nresources: |`n`n"
                "`evidences:`n    - path: 'evidences/" + $reader["file_name"] +".docx'"
                "`nrisk: |`n" + $reader["risk"]
                "`nrecommendation: |`n" + $reader["recommendation"]
                Write-Output "`n---------------------------------------------------------`n"

                #Save to file
                if($OutFile -ne "") {
                    #Build yml string
                    $YmlStr = ""
                    $YmlStr += "rating: """ + $reader["rating"] + """"
                    $YmlStr += "`r`nname: """ + $reader["name"] + """"
                    $YmlStr += "`r`n`r`ncvss_score: """ + $reader["cvss_score"] + """"
                    $YmlStr += "`r`ncvss_vector: """ + $reader["cvss_vector"] + """"
                    $YmlStr += "`r`ncwe: """ + $reader["cwe"] + """"
                    $YmlStr += "`r`n`r`nobservation: |`r`n" + $reader["observation"]
                    $YmlStr += "`r`n`r`nresources: |`r`n    `r`n"
                    $YmlStr += "`r`nevidences:`r`n    - path: 'evidences/" + $reader["file_name"] +".docx'"
                    $YmlStr += "`r`n`r`nrisk: |`r`n" + $reader["risk"]
                    $YmlStr += "`r`n`r`nrecommendation: |`r`n" + $reader["recommendation"]
                    
                    #Write yml content to file
                    Set-Content -Path $OutFile -Value $YmlStr -NoNewline
                }
            }
        }

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}

function Get-FindingByName {
    param (
        [string]$Name
    )

    if($Name -eq "") {
        Write-Output "Missing Name parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE (file_name LIKE @Name) OR (name LIKE @Name)"
        $cmd.Parameters.AddWithValue("@Name", "%" + $Name + "%") > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                "[id: " + $reader["id"] + "]"
                "[file_name: " + $reader["file_name"] + "]"
                Write-Output "--------"
                "rating: """ + $reader["rating"] + """"
                "name: """ + $reader["name"] + """"
                Write-Output ""
                "cvss_score: """ + $reader["cvss_score"] + """"
                "cvss_vector: """ + $reader["cvss_vector"] + """"
                "cwe: """ + $reader["cwe"] + """"
                "`nobservation: |`n" + $reader["observation"]
                "`nrisk: |`n" + $reader["risk"]
                "`nrecommendation: |`n" + $reader["recommendation"]
                Write-Output "`n---------------------------------------------------------`n"
            }
        }

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}

function Get-FindingByContent {
    param (
        [string]$Content
    )

    if($Content -eq "") {
        Write-Output "Missing Content parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE (file_name LIKE @Content) OR (rating LIKE @Content) "
        $cmd.CommandText += "OR (name LIKE @Content) OR (cvss_score LIKE @Content) OR (cvss_vector LIKE @Content) "
        $cmd.CommandText += "OR (cwe LIKE @Content) OR (observation LIKE @Content) OR (risk LIKE @Content)"
        $cmd.CommandText += "OR (recommendation LIKE @Content)"
        $cmd.Parameters.AddWithValue("@Content", "%" + $Content + "%") > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                "[id: " + $reader["id"] + "]"
                "[file_name: " + $reader["file_name"] + "]"
                Write-Output "--------"
                "rating: """ + $reader["rating"] + """"
                "name: """ + $reader["name"] + """"
                Write-Output ""
                "cvss_score: """ + $reader["cvss_score"] + """"
                "cvss_vector: """ + $reader["cvss_vector"] + """"
                "cwe: """ + $reader["cwe"] + """"
                "`nobservation: |`n" + $reader["observation"]
                "`nrisk: |`n" + $reader["risk"]
                "`nrecommendation: |`n" + $reader["recommendation"]
                Write-Output "`n---------------------------------------------------------`n"
            }
        }

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}

function Get-IdByName {
    param (
        [string]$Name
    )

    if($Name -eq "") {
        Write-Output "Missing Name parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE (file_name LIKE @Name) OR (name LIKE @Name)"
        $cmd.Parameters.AddWithValue("@Name", "%" + $Name + "%") > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        "[ids with the search string: $($Name)]"
        $RecordCount = 0
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                Write-Output $reader["id"]
                $RecordCount++
            }
        }
        Write-Output "`nTotal count of records: $($RecordCount)"
        Write-Output "`n---------------------------------------------------------`n"

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}

function Get-IdByContent {
    param (
        [string]$Content
    )

    if($Content -eq "") {
        Write-Output "Missing Content parameter!"
    }
    else {
        # Connect to db
        $dbPath = "C:\Users\gvajda\Documents\WebYmlFileRepo\web_finding_repo.db"
        $conStr = "Data Source=$dbPath"
        $sqlCon = New-Object System.Data.SQLite.SQLiteConnection
        $sqlCon.ConnectionString = $conStr
        $sqlCon.Open()

        # Query data from db
        $cmd = $sqlCon.CreateCommand()
        $cmd.CommandType = [System.Data.CommandType]::Text
        $cmd.CommandText = "SELECT * FROM findings WHERE (file_name LIKE @Content) OR (rating LIKE @Content) "
        $cmd.CommandText += "OR (name LIKE @Content) OR (cvss_score LIKE @Content) OR (cvss_vector LIKE @Content) "
        $cmd.CommandText += "OR (cwe LIKE @Content) OR (observation LIKE @Content) OR (risk LIKE @Content)"
        $cmd.CommandText += "OR (recommendation LIKE @Content)"
        $cmd.Parameters.AddWithValue("@Content", "%" + $Content + "%") > $null #redirect to null needed because its prints technical data to stdout
        $cmd.Prepare()
        $reader = $cmd.ExecuteReader()
        
        # print rows
        Write-Output "[rows]`n"
        "[ids with the search string: $($Content)]"
        $RecordCount = 0
        while ($reader.HasRows)
        {
            if($reader.Read())
            {
                Write-Output $reader["id"]
                $RecordCount++
            }
        }
        Write-Output "`nTotal count of records: $($RecordCount)"
        Write-Output "`n---------------------------------------------------------`n"

        # Close connection
        $reader.Close()
        $sqlCon.Close()
    }
}


# Auto called statements
Init