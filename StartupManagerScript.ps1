pushd (split-path $MyInvocation.MyCommand.Path -Parent)  # Команда используется для перехода в директорию, где находится файл скрипта

$isfileexists = test-path script.cfg                     # Проверка на существование конфигурационного файла

if (!$isfileexists)
{
	new-item script.cfg                                  # Если файла нет, создаём его и записываем туда значения полей существующих служб
    foreach ($service in get-service) {
        $serviceCurrentName = $service.name
        $serviceCurrentDisplayName = $service.displayname
        $serviceCurrentStartType = $service.starttype
        $serviceCurrentStatus = $service.status
        "$serviceCurrentName|displayname:$serviceCurrentDisplayName;starttype:$serviceCurrentStartType;status:$serviceCurrentStatus" | out-file -filepath script.cfg -append
}
	# "TestName|displayname:Test Service;description:Description of test service;starttype:automatic;status:stopped" | out-file -filepath script.cfg
}
else {

	foreach($res in get-content -path .\script.cfg -Encoding UTF8) {          # Обрабатываем все записи в файле

		$res = $res -split "\|"

		$serviceName = $res[0]

		$serviceSettings = $res[1]
		$serviceSettings = $serviceSettings -split ";"   # Готовим данные к интерпретации

		foreach ($setting in $serviceSettings) {
			$setting = $setting -split ":"
			$settingName = $setting[0]
			$settingValue = $setting[1]
			switch ($settingName) {                      # Обрабатываем возможные параметры служб
				"displayname" {get-service $serviceName | set-service -displayname $settingValue}
				"description" {get-service $serviceName | set-service -Description "$settingValue"}
				"starttype" {get-service $serviceName | set-service -startuptype $settingValue}
				"status" {get-service $serviceName | set-service -status $settingValue}
			}
		}
		Get-Service $serviceName | Select-Object -property Name, displayname, StartType, Status | Format-List 
		Get-CimInstance Win32_Service -filter "Name = '$serviceName'" | Format-List Description
														 # Выводим новую информацию о модулях
	}
}
popd                                                     # Возвращаемся в исходную директорию
pause