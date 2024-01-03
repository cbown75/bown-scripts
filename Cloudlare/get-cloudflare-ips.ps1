function get-cf-ips()
{
    $rtn = ""

    $cfips = (Invoke-RestMethod -uri "https://api.cloudflare.com/client/v4/ips" -method GET | ConvertTo-Json)

    #Write-Host ($cfips | ConvertFrom-Json)
    $cfips = ($cfips | ConvertFrom-Json)

    foreach($cfip in $cfips.result.ipv4_cidrs)
    {
        $rtn = $rtn + $cfip + ","
    }

    if($rtn.EndsWith(","))
    {
        $rtn = $rtn.Remove($rtn.Length-1, 1)
    }

    return $rtn
}

get-cf-ips
