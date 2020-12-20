# MIT License
# Copyright (c) 2020 pegaeae

function Get-ClickUpTeams {
    param (
        [string]$Token
    )

    begin {
       $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
    }
    process {
        $url = "https://api.clickup.com/api/v2/team"
        try{$ret = Invoke-WebRequest -Method Get -Headers $headers -Uri $url} catch{}
        if ($ret.StatusCode -eq 200) {
            return $ret.content
        } else {
            return "{""teams"":[]}";
        }
        
    }
    end {}
}

function Get-ClickUpGoals {
    param (
        [string]$Token,
        [string]$TeamID
    )

    begin {
       $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
    }
    process {
        $url = "https://api.clickup.com/api/v2/team/$TeamID/goal"
        $ret = Invoke-WebRequest -Method Get -Headers $headers -Uri $url
        if ($ret.StatusCode -eq 200) {
            return $ret.content
        } else {
            return "{""goals"":[]}";
        }
    }
    end {}
}

function Get-ClickUpTasks {
    param (
        [string]$Token,
        [string]$ListID
    )

    begin {
       $headers = @{
            "Authorization" = $Token
            "Content-Type" = "application/json"
        }
    }
    process {
        $url = "https://api.clickup.com/api/v2/list/" + $ListID + "/task?archived=false&page="
        $page = 0
        $tasks = ""
        Do {
            $ret = Invoke-WebRequest -Method Get -Headers $headers -Uri ($url + $page)
            if ($ret.StatusCode -eq 429) {
                write-warning "trop de requete en 1 minutes (max 100/min)"
                sleep -Seconds 65
                continue
            }
            if ($ret.StatusCode -ne 200) {break}
            $json = ConvertFrom-Json -InputObject $ret.content
            if ($json.tasks.count -gt 0) {
                if ($tasks -ne "") {
                    $tasks = ($tasks -replace “..$”) + "," + ($ret.Content -replace "^{.tasks.:\[")
                } else {$tasks = $ret.content}
                $page = $page + 1
            }
        } until ($json.tasks.count -ne 100)
        return $tasks
    }
    end {}
}