$path = "R:\Movies\"

$items = Get-ChildItem -Path $path -Filter "*.mkv" -Recurse

foreach($item in $items)
{
    $directory = $item.DirectoryName.ToString()
    $filename = $item.Name.ToString()
    $folders = $directory.Split("\")
    $parent = $folders[$folders.GetUpperBound(0)]
    $filex = $filename.Replace(".mkv", "")
    $lfilex = $filex.ToLower()

    if($parent -ne $filex)
    {
        switch($lfilex)
        {
            {$_.EndsWith("pt. 1")}
            {
                break
            }
            {$_.EndsWith("pt. 2")}
            {
                break
            }
            {$_.EndsWith("pt. 3")}
            {
                break
            }
            {$_.EndsWith("pt. 4")}
            {
                break
            }
            {$_.EndsWith("pt. 5")}
            {
                break
            }
            {$_.EndsWith("pt. 6")}
            {
                break
            }
            {$_.EndsWith("pt 1")}
            {
                break
            }
            {$_.EndsWith("pt 2")}
            {
                break
            }
            {$_.EndsWith("disc1")}
            {
                break
            }
            {$_.EndsWith("disc2")}
            {
                break
            }
            {$_.EndsWith("disc3")}
            {
                break
            }
            Default {
                $oldpath = $item.FullName
                $newpath = "$directory\$filex"
                $newfile = "$directory\$filex\$filename"
                if(!(Test-Path -Path $newpath))
                {
                    Write-Host "Create Folder: $filex" -ForegroundColor Green
                    New-Item -Path $directory -Name $filex -ItemType "directory"
                }
                if(!(Test-Path -Path $newfile))
                {
                   Write-Host "Move File: $newfile" -ForegroundColor Cyan
                   Move-Item -Path $oldpath -Destination $newfile
                }
                Write-Host ""
                break
            }


        }
    }
}