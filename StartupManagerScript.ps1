pushd (split-path $MyInvocation.MyCommand.Path -Parent)  # ������� ������������ ��� �������� � ����������, ��� ��������� ���� �������

$isfileexists = test-path script.cfg                     # �������� �� ������������� ����������������� �����

if (!$isfileexists)
{
	new-item script.cfg                                  # ���� ����� ���, ������ ��� � ���������� ���� �������� ����� ������������ �����
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

	foreach($res in get-content -path .\script.cfg -Encoding UTF8) {          # ������������ ��� ������ � �����

		$res = $res -split "\|"

		$serviceName = $res[0]

		$serviceSettings = $res[1]
		$serviceSettings = $serviceSettings -split ";"   # ������� ������ � �������������

		foreach ($setting in $serviceSettings) {
			$setting = $setting -split ":"
			$settingName = $setting[0]
			$settingValue = $setting[1]
			switch ($settingName) {                      # ������������ ��������� ��������� �����
				"displayname" {get-service $serviceName | set-service -displayname $settingValue}
				"description" {get-service $serviceName | set-service -Description "$settingValue"}
				"starttype" {get-service $serviceName | set-service -startuptype $settingValue}
				"status" {get-service $serviceName | set-service -status $settingValue}
			}
		}
		Get-Service $serviceName | Select-Object -property Name, displayname, StartType, Status | Format-List 
		Get-CimInstance Win32_Service -filter "Name = '$serviceName'" | Format-List Description
														 # ������� ����� ���������� � �������
	}
}
popd                                                     # ������������ � �������� ����������
pause