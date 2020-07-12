## Var/Conts
$key_tides = "realkey"
$hours_fishing = @(6..12+18..22)
$hours_cruising = @(10..16)
$lat = "40.638909"
$lon = "-73.540501"
$woeid = "2459115"
$temp_fishing = 18.0
$temp_cruising = 23.5
$wind_fishing = 12
$wind_cruising = 8
$weather_fishing = @("s","hc","lc","c")
$weather_cruising = @("lc","c")
$days = 5
$uri_tides_base = "https://www.worldtides.info/api/v2"
$uri_weather_base = "https://www.metaweather.com/api"
$Global:nl = [System.Environment]::NewLine

## Calculated Vars / Setup
$uri_tides = "$($uri_tides_base)?extremes&date=$((Get-Date).ToString("yyyy-MM-dd"))&lat=$lat&lon=$lon&days=$days&key=$key_tides"
$uri_weather = "$($uri_weather_base)/location/$woeid/"

## Local Functions
function Get-GoodDays ($data_tides,$hours,$good_weather) {
    $good_days = @()
    $data_tides.extremes | Where-Object {$_.type -ieq "High"} | ForEach-Object {
        $c_date = Get-Date $_.date
        if (($c_date.TimeOfDay.Hours) -in $hours) {
            $c_wthr = $good_weather | Where-Object {$_.applicable_date -eq ($c_date).ToString("yyyy-MM-dd")}
            if ($c_wthr) {
                $good_days += @{"tide"=$_;"weather"=$c_wthr;}
            }
        }
    }
    return $good_days
}

function ConvertTo-Farenheit ($celcius) {
    return [Math]::Round((($celcius * 9/5) + 32),0)
}

function Write-GoodDays ($type,$good_days) {
    $output = ""
    if (($good_days | Measure-Object).Count -ge 1) {
        $output += "$type times:$($Global:nl)"
        $good_days | ForEach-Object{
            $c_date = Get-Date $_.tide.date
            $output += " $($c_date.ToShortDateString()) $($c_date.AddHours(-2).ToShortTimeString()) - $($c_date.AddHours(2).ToShortTimeString())$($Global:nl)"
            $output += " $($_.weather.weather_state_name) - $(ConvertTo-Farenheit $_.weather.max_temp)f$($Global:nl)"
            $output += " Humidity: $($_.weather.humidity)%$($Global:nl)"
            $output += " Temp: $(ConvertTo-Farenheit $_.weather.min_temp)f - $(ConvertTo-Farenheit $_.weather.max_temp)f$($Global:nl)"
            $output += " Wind: $([Math]::Round($_.weather.wind_speed,1))mph $($_.weather.wind_direction_compass)$($Global:nl)"
            $output += " "+"*"*30+$($Global:nl)
        }
    }
    else {
        $output += "No good $type times found$($Global:nl)"
    }
    return $output
}


## Get Data
$data_tides = Invoke-RestMethod -Method Get -Uri $uri_tides
$data_weather = Invoke-RestMethod -Method Get -Uri $uri_weather

## Sort / Filter
$good_weather_fishing = $data_weather.consolidated_weather | Where-Object {($_.max_temp -ge $temp_fishing) -and ($_.wind_speed -le $wind_fishing) -and ($_.weather_state_abbr -iin $weather_fishing)}
$good_weather_cruising = $data_weather.consolidated_weather | Where-Object {($_.max_temp -ge $temp_cruising) -and ($_.wind_speed -le $wind_cruising) -and ($_.weather_state_abbr -iin $weather_cruising)}

## Get Good Days
$fishing = Get-GoodDays $data_tides $hours_fishing $good_weather_fishing
$cruising = Get-GoodDays $data_tides $hours_cruising $good_weather_cruising

## Build Result
Write-GoodDays "Cruising" $cruising
Write-GoodDays "Fishing" $fishing