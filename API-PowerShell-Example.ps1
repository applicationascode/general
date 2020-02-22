$ip = Invoke-RestMethod -uri http://ipinfo.io/json | Select -exp ip
$city = (Invoke-RestMethod -uri "https://api.ipgeolocation.io/ipgeo?apiKey=00718fd5c84d4f8e9c86c7b0f885e3ee&ip=$ip").city
$weer = (Invoke-RestMethod -uri "http://vdnborn.nl:1337/getweer?locatie=$city" -Method GET).liveweer
$temp = $weer.temp

write-host "Hai you are in $city and the temperature is $temp celcius."
