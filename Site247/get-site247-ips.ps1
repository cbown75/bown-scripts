function get-site24x7-ips
{
    $rtn = ""
    $url = "https://creatorexport.zoho.com/site24x7/location-manager/json/IP_Address_View/C80EnP71mW2fDd60GaDgnPbVwMS8AGmP85vrN27EZ1CnCjPwnm0zPB5EX4Ct4q9n3rUnUgYwgwX0BW3KFtxnBqHt60Sz1Pgntgru/"

    $resp = Invoke-RestMethod -Method GET -Uri $url

    $ips = ($resp.LocationDetails | ConvertTo-Json)

    foreach($ip in $ips)
    {
        if($ip.Place -eq "US")
        {
            $rtn = $rtn + $ip.external_ip + ","
        }
    }

    if($rtn.EndsWith(","))
    {
        $rtn = $rtn.Remove($rtn.Length-1, 1)
    }

    return $rtn
}
