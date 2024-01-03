function CF-Update-Site247-IPs()
{
    $headers = @{}
    $headers.Add("X-Auth-Email","")
    $headers.Add("X-Auth-Key","")

    $uri = "https://api.cloudflare.com/client/v4/accounts?page=1&per_page=50&direction=desc"

    $accounts = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

    $247ips = Get-Site24x7-IPs

    foreach($account in $accounts.result)
    {
        if($account.net -ne "CVNA IT")
        {
            #Write-Host "Account " $account.name


            $uri = "https://api.cloudflare.com/client/v4/zones?account.id=" + $account.id + "&direction=desc&match=all&status=active"

            #Write-Host $uri
            $zones = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

            #Write-Host ($zones | ConvertTo-json)

            foreach($zone in $zones.result)
            {
                #Write-Host "Zone: " $zone.name

                $uri = "https://api.cloudflare.com/client/v4/zones/" + $zone.id + "/firewall/rules?paused=false&page=1&per_page=50&description=Allow_Site24x7"

                $rules = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

                #Write-Host ($rules | ConvertTo-json)

                foreach($rule in $rules.result)
                {
                    $uri = ""
                    $newrule = ""
                    $output = ""
                    $body = ""
                    Write-Host $rule.description

                    if($rule.description.Contains("Cali"))
                    {
                        $newrule = Format-IPs $247ips $true
                    }
                    else
                    {
                        $newrule = Format-IPs $247ips $false
                    }

                    $uri = "https://api.cloudflare.com/client/v4/zones/" + $zone.id + "/filters/" + $rule.filter.id


                    $body = $body +"{`"id`":`"" + $rule.filter.id + "`","
                    $body = $body +"`"expression`":`"" + $newrule + "`""
                    $body = $body + "}"

                    Write-Host $body

                    $output = Invoke-RestMethod -Method PUT -Headers $headers -ContentType "application/json" -Body $body -uri $uri -Verbose

                    Write-Host ($output | ConvertTo-Json)
                }
            }
        }
    }
}


function CF-Update-CVNA-IPs()
{
    $headers = @{}
    $headers.Add("X-Auth-Email","")
    $headers.Add("X-Auth-Key","")

    $uri = "https://api.cloudflare.com/client/v4/accounts?page=1&per_page=50&direction=desc"

    $accounts = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

    $247ips = Get-Site24x7-IPs

    foreach($account in $accounts.result)
    {
        #Write-Host "Account " $account.name


        $uri = "https://api.cloudflare.com/client/v4/zones?account.id=" + $account.id + "&direction=desc&match=all&status=active"

        #Write-Host $uri
        $zones = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

        #Write-Host ($zones | ConvertTo-json)

        foreach($zone in $zones.result)
        {
            #Write-Host "Zone: " $zone.name

            $uri = "https://api.cloudflare.com/client/v4/zones/" + $zone.id + "/firewall/rules?paused=false&page=1&per_page=50&description=Allow_CVNA"

            $rules = Invoke-RestMethod -Method GET -Headers $headers -ContentType "application/json" -uri $uri

            #Write-Host ($rules | ConvertTo-json)

            foreach($rule in $rules.result)
            {
                $uri = ""
                $newrule = ""
                $output = ""
                $body = ""
                Write-Host $rule.description

                if($rule.description.Contains("VPN"))
                {
                    $newrule = ""
                }
                else
                {
                    $newrule = Format-IPs $247ips $false
                }

                $uri = "https://api.cloudflare.com/client/v4/zones/" + $zone.id + "/filters/" + $rule.filter.id


                $body = $body +"{`"id`":`"" + $rule.filter.id + "`","
                $body = $body +"`"expression`":`"" + $newrule + "`""
                $body = $body + "}"

                Write-Host $body

                $output = Invoke-RestMethod -Method PUT -Headers $headers -ContentType "application/json" -Body $body -uri $uri -Verbose

                Write-Host ($output | ConvertTo-Json)
            }
        }
    }
}

function Format-IPs($site247ips, [bool]$includeca)
{
    $site247ips = ($site247ips | ConvertFrom-Json)

    $rtn = ""

    foreach($sip in $site247ips)
    {
        if($sip.Place -eq "US")
        {
            if($includeca)
            {
                if($sip.City.Contains("-CA") -or $sip.City -eq "Los Angeles" -or $sip.City -eq "San Francisco")
                {
                    if($sip.external_ip.Contains("/"))
                    {
                        $ipitem = "(ip.src in {" + $sip.external_ip + "}) or "
                        $rtn = $rtn + $ipitem
                    }
                    else
                    {
                        $ipitem = "(ip.src eq " + $sip.external_ip + ") or "
                        $rtn = $rtn + $ipitem
                    }

                    if($sip.IPv6_Address_External -ne "")
                    {
                        $ipitem = "(ip.src eq " + $sip.IPv6_Address_External + ") or "
                        $rtn = $rtn + $ipitem
                    }
                }
            }
            else
            {
                if(!$sip.City.Contains("-CA") -and $sip.City -ne "Los Angeles" -and $sip.City -ne "San Francisco")
                {
                    if($sip.external_ip.Contains("/"))
                    {
                        $ipitem = "(ip.src in {" + $sip.external_ip + "}) or "
                        $rtn = $rtn + $ipitem
                    }
                    else
                    {
                        $ipitem = "(ip.src eq " + $sip.external_ip + ") or "
                        $rtn = $rtn + $ipitem
                    }

                    if($sip.IPv6_Address_External -ne "")
                    {
                        $ipitem = "(ip.src eq " + $sip.IPv6_Address_External + ") or "
                        $rtn = $rtn + $ipitem
                    }
                }
            }
        }
    }

    if($rtn.EndsWith(" or "))
    {
        $rtn = $rtn.Substring(0,$rtn.Length-4)
    }

    return $rtn.Trim()
}

function Is-IP-In-List([string]$iptofind, $list)
{
    $rtn = $false
    Write-Host $iptofind

    $list = ($list | ConvertFrom-Json)

    #Write-Host $list
    foreach($ip in $list)
    {
        
        #Write-Host $ip.external_ip
        if($iptofind -eq $ip.external_ip)
        {
            Write-Host $iptofind
            $rtn = $true
            break
        }
    }

    return $rtn
}


function Get-Site24x7-IPs
{
    $filename = "Site24x7.json"
    $url = "https://creatorexport.zoho.com/site24x7/location-manager/json/IP_Address_View/C80EnP71mW2fDd60GaDgnPbVwMS8AGmP85vrN27EZ1CnCjPwnm0zPB5EX4Ct4q9n3rUnUgYwgwX0BW3KFtxnBqHt60Sz1Pgntgru/"

    $resp = Invoke-RestMethod -Method GET -Uri $url

    $ips = ($resp.LocationDetails | ConvertTo-Json)

    return $ips
}

function Parse-CF-IPs([string]$exps)
{
    $cfips = $exps -split("or")

    $outips = @()

    for($i=0; $i -le $cfips.GetUpperBound(0); $i++)
    {
        $cfips[$i] = $cfips[$i].Replace(")", "")
        $cfips[$i] = $cfips[$i].Replace("(", "")
        $cfips[$i] = $cfips[$i].Replace("ip.src eq", "")
        $cfips[$i] = $cfips[$i].Trim()
        $outips += @{IP=$cfips[$i]}
    }

    $outips = ($outips | ConvertTo-Json)

    return $outips
}

CF-Update-Site247-IPs

#Get-Site24x7-IPs
