#version 3.2.0.1
param( 
    [Parameter(Mandatory=$true)]
    #[ValidateSetAttribute('start','stop','createorupdate')]
    [string] $action = "", # [start,stop,createorupdate,config]

    [Parameter()]
    [string] $server = ".",

    [Parameter()]
    [string] $user ="",

    [Parameter()]
    [string] $password ="",

    [Parameter(Mandatory=$true)]
    [string[]] $serviceName = "", #srv1,srv2

    [Parameter()]
    [string[]] $processName = "", #omid.srv1.exe,omid.srv2.exe

    [Parameter()]
    [string] $displayName="", #Asa Session-Timeout Manager

    [Parameter()]
    [string] $binaryPath="", #D:\Asa\Agents\Current\SessionTimeoutManager\Asa.Online.SessionTimeoutManager.exe

    [Parameter()]
    [string] $dependsOn="", #dependsOn

    [Parameter()]
    #[Parameter(HelpMessage="Start type for the service [start=boot, system, auto, demand, disabled] (default=auto)")]
    #[ValidateSet('start','boot','system','auto','demand','disabled')]
    [string] $startType = "", #Option values include types used by drivers.(default = demand)

    [Parameter()]
    [string] $description="",

    [Parameter()]
    [int] $trycount = 5,

    [Parameter()]
    [int] $delayBetweenTries = 10,

    [Parameter()]
    [bool] $ignoreStopIfNotExists = $true #if set to false show error The specified service does not exist as an installed service
     ) 

$isRemote = 1
if($server -eq "" -or $server -eq "." -or $server -eq "local")
{
  $isRemote = 0
  $server = "\\." # ooni ke local ghabool mikone
}
function StartOneOrMoreServices()
{
   
    if($isRemote -eq 1)
    {
        net use $server\IPC$ /user:$user $password
    }
    
    if($LASTEXITCODE -eq 1326) {
        Write-Host "The user name or password is incorrect."
    }
    elseif($LASTEXITCODE -ne 0){
        Write-Host "System error $errorCode has occurred."
    }

    foreach($service in $serviceName.Split(","))
    {
		StartService $service $trycount $delayBetweenTries
    }
	if($isRemote -eq 1)
	{
		net use $server\IPC$ /delete
	}
}
#End function StartOneOrMoreServices()

# StartService works only for local connections
function StartService($service, $trycount, $delayBetweenTries){

	$errorCode = 999

	for($i=0; ($i -le $trycount) -and ($errorCode -ne 0); $i++)
	{
		Write-Host "Service: '$service' i: '$i' trycount: '$trycount' LastExitCode: '$LASTEXITCODE' errorCode: '$errorCode'"
		if($i -ne 0)
		{
			Write-Host "Waiting $delayBetweenTries seconds for starting service ..."
			Start-Sleep -s $delayBetweenTries
		}
		$result = sc.exe $server start $service #Start Service
		$errorCode = $LASTEXITCODE

		if($errorCode -eq 1056) {
			Write-Host "Starting service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: An instance of the service is already running" -foregroundcolor Yellow
			break;
		}
		elseif($errorCode -eq 0)
		{
			Write-Host "The '$service' service on '$server' server started successfully" -foregroundcolor green
			break;
		} # else an ERROR occured
		elseif ($errorCode -eq 1053)
		{
			Write-Error "An error occurred in starting service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service did not respond to the start or control request in a timely fashion"
		}
		elseif ($errorCode -eq 1060)
		{
			Write-Error "An error occurred in starting service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service"
		}
		elseif ($errorCode -eq 1061)
		{
			Write-Error "An error occurred in starting service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service cannot accept control messages at this time"
		}
		elseif ($errorCode -eq 1062)
		{
			Write-Error "An error occurred in starting service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service has not been started"
		}
		else
		{
			Write-Error "an error occurred in starting service '$service' on server '$server'. errorcode: '$errorCode'"
			break;
		}
	}
}
#End function StartService()

function StopOneOrMoreService()
 {
    if($serviceName.Count -ne $processName.Count)
    {
        Write-Error "Invalid parameters. services count does not equal to processes count"
    }

    if($isRemote -eq 1)
    {
      net use $server\IPC$ /user:$user $password
    }
    
    if($LASTEXITCODE -eq 1326) {
        Write-Host "The user name or password is incorrect."
    }
    elseif($LASTEXITCODE -ne 0){
        Write-Host "System error $errorCode has occurred."
    }
        
    [string[]] $servicesArray = $serviceName.Split(",")
    [string[]] $processesArray = $processName.Split(",")
        
    for($j = 0 ; $j -lt $servicesArray.Count; $j++)
    {
        [string] $service = $servicesArray.Get($j)
        [string] $process = $processesArray.Get($j)
		
		StopService $service $trycount $delayBetweenTries $ignoreStopIfNotExists
		
		if($isRemote -eq 1)
		{
			#Do Nothing
		}
		else
		{
			StopProcess $process $trycount $delayBetweenTries $ignoreStopIfNotExists
		}
    }
	 
	if($isRemote -eq 1)
	{
		net use $server\IPC$ /delete
	}
    return $errorCode;

}
#End function StopOneOrMoreService()


# StopService works only for local connections
function StopService($service, $trycount, $delayBetweenTries, $ignoreStopIfNotExists)
{
	$errorCode = 999
	for($i=0; $i -le $trycount; $i++)
	{
		Write-Host "Service: '$service' i: '$i' trycount: '$trycount' LastExitCode: '$LASTEXITCODE' errorCode: '$errorCode'"
		if($i -ne 0)
		{
			Write-Host "Waiting 5 seconds for stopping service ..."
			Start-Sleep -s $delayBetweenTries
		}
		$result = sc.exe $server stop $service #Stop Service
		$errorCode = $LASTEXITCODE
		if($errorCode -eq 0) {
			Write-Host "Stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The operation completed successfully." -foregroundcolor green
			break;
		}
		elseif($errorCode -eq 1062) {
			Write-Host "Stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service has not been started" -foregroundcolor Yellow
			break;
		}
		elseif ($ignoreStopIfNotExists -eq 1 -and $errorCode -eq 1060)
		{
			Write-Host "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service" -foregroundcolor Yellow
			break;
		}
		else
		{
			if ($errorCode -eq 1053)
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service did not respond to the start or control request in a timely fashion"
			}
			elseif ($errorCode -eq 1056)
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: An instance of the service is already running"
			}
			elseif ($ignoreStopIfNotExists -eq 0 -and $errorCode -eq 1060)
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service"
			}
			elseif ($errorCode -eq 1061)
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The service cannot accept control messages at this time"
			}
			elseif ($errorCode -eq 2242)
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: password expired"
			}
			else
			{
				Write-Error "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE"
			}
		} 
	}
}
#End function StopService()

function StopProcess($process, $trycount, $delayBetweenTries, $ignoreStopIfNotExists)
{
	#Check Service is still is running
	#fe'lan remote ra check nemikonim
	$proccess = Get-Process $process -ErrorAction silentlycontinue
	if($proccess -ne $null)
	{
		for($i=1; $i -le $trycount; $i++)
		{
			Write-Host "Waiting $delayBetweenTries seconds for closing [$process] process || TryCount : $i of  $trycount ..."
			Start-Sleep -s $delayBetweenTries
			$proccess = Get-Process $process -ErrorAction silentlycontinue

			if($proccess -eq $null)
			{
				break;
			}
			elseif($i -eq $trycount)
			{
				#Stop-Process -Name "mmc" #todo need full test

				#Kill the process if still exists
				Write-Host "Kill the process [$process] ... "
				Stop-Process -Name $process -Force
			}
		}
	}
}

function CreateOrUpdate()
{
    #فراخوانی استاپ کردن ویندوز سرویس که نام سرویس و نام پراسس آن باید ست شود
    #Check Service Is Installed-if service installed must return 0 (zero) errorcode
    
    sc.exe query $serviceName 
    $errorcode=$LASTEXITCODE

    if($errorcode -eq 1060) #errorcode 1060 yani service nasb nist
    {
        if($dependsOn -ne "")
        {
            sc.exe create $serviceName  binPath="$binaryPath" start= $startType DisplayName="$displayName" depend=$dependsOn
        }
        else
        {
            sc.exe create $serviceName  binPath="$binaryPath" start= $startType DisplayName="$displayName"
        }
        $createError=$LASTEXITCODE
    }
    else
    {
        if($dependsOn -ne "")
        {
            sc.exe config $serviceName  binPath="$binaryPath" start= $startType DisplayName="$displayName" depend=$dependsOn
        }
        else
        {
            sc.exe config $serviceName  binPath="$binaryPath" start= $startType DisplayName="$displayName"
            $error=$LASTEXITCODE
        }
    }
}
#End function CreateOrUpdate()


if($action -eq "start")
{
	StartOneOrMoreServices
}
elseif($action -eq "stop")
{
    StopOneOrMoreService
}
elseif($action -eq "createorupdate")
{
    CreateOrUpdate
} 
else
{
    Write-Error "Action '$action' is not defined";
}
 

#Problem
#[SC] OpenSCManager FAILED 5:
#Access is denied.

#Solution
#http://answers.microsoft.com/en-us/windows/forum/windows_vista-windows_programs/scexe-create-causes-access-denied-error/9369af3f-7966-4557-b9a5-ffe53cf40ca5
#Have you tried to run the command in elevated command prompt?
# 
#However, you may first try to enable the default administrator on your computer and later try to run the command in elevated command prompt and verify if your are able to run the command successfully.
# 
#To enable the default Administrator account, perform the steps below:
#1. Click Start and type CMD in the Start search box
#2. Right click on CMD in the list and click on "Run as administrator"
#3. Type the following command: net user administrator /active:yes
# 
#Restart the computer and you should see an "Administrator" account. 
# 
#Access Administrator account and follow the steps 1 and 2 and try to run the command.
# 
#Also let us know if you are connected to a network or a domain network.
