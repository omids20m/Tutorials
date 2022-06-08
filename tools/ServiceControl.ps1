#version 3.1.1
<#
.SYNOPSIS
    Service utils
.DESCRIPTION
    Created by Omid Shariati http://HiDevOps.com http://OmidShariati.com
.PARAMETER machineName
    Specifies target machine name.
#>
[CmdletBinding()]
param( 
    #[Alias("a")]
    [Parameter(Mandatory=$true)]
    [ValidateSet('start','stop','createorupdate')] #...,config
    [string] $action = "",
	
    #[Alias("machine")]
    [Parameter()]
    [string] $machineName = ".",

    #[Alias("user")]
    [Parameter(HelpMessage="Remote machine Username")]
    [string] $username ="",

    #[Alias("pass")]
    [Parameter(HelpMessage="Remote machine Password")]
    [string] $password ="",

    #Service name. Accepts comma separated for start/stop actions
    #[Alias("name")]
    [Parameter(Mandatory=$true)]
    [string[]] $serviceName = "",

    [Parameter(HelpMessage="Process name. Accepts comma separated for stop actions")]
    #[Alias("process")]
    [string[]] $processName = "", #Accepts comma separated for stop action

    #[Alias("count")]
    [Parameter(HelpMessage="Number of tries for start/stop action if not succcessfull")]
    [int] $trycount = 5, #for start and stop actions

    #[Alias("delay")]
    [Parameter(HelpMessage="Delay between tries in second for start/stop actions")]
    [int] $delayBetweenTries = 10,

    #[Alias("display")]
    [Parameter(HelpMessage="Service display name for createorupdate action")]
    [string] $serviceDisplayName = "", 
    
    #[Alias("path")]
    [Parameter(HelpMessage="Binary path of service to be created of updated. for createorupdate action")]
    [string] $binaryPath = "",  #"D:\Agents\Current\Text.exe",
    
    #[Alias("depends")]
    [Parameter(HelpMessage="Name of services in csv that this service depends on. for createorupdate action")]
    [string] $servicesDependedOn = "",

    #[Alias("start")]
    [Parameter(HelpMessage="Start type for the service [start=boot, system, auto, demand, disabled] (default=auto)")]
    [ValidateSet('start','boot','system','auto','demand','disabled')]
    [string] $startType = "auto", #Option values include types used by drivers.(default = demand)
    
    #[Alias("desc")]
    #[Parameter(HelpMessage="Service description"). for createorupdate action]
    #[string] $newServiceDescription = "", #for createorupdate action
	
    #[Alias("ignore")]
    [Parameter()]
    [bool] $ignoreStopIfNotExists= $true #$false #if set to false show error The specified service does not exist as an installed service
     ) 

$isRemote = 1
if($machineName -eq "" -or $machineName -eq "." -or $machineName -eq "local")
{
    $isRemote = 0
    $machineName = "\\." # ooni ke local ghabool mikone
}

function StartService()
{
<#

.SYNOPSIS
Start a service on local or remote machine.

#>
    if($isRemote -eq 1)
    {
        net use $machineName\IPC$ /user:$username $password
    }
    
    if($LASTEXITCODE -eq 1326) {
        Write-Host "The user name or password is incorrect."
    }
    elseif($LASTEXITCODE -ne 0){
        Write-Host "System error $errorCode has occurred."
    }

    foreach($service in $serviceName.Split(","))
    {
        $errorCode = 999

        for($i=0; ($i -le $trycount) -and ($errorCode -ne 0); $i++)
        {
            Write-Host "Service: '$service' i: '$i' trycount: '$trycount' LastExitCode: '$LASTEXITCODE' errorCode: '$errorCode'"
            if($i -ne 0)
            {
                Write-Host "Waiting 10 seconds for starting service ..."
                Start-Sleep -s $delayBetweenTries
            }
            $result = sc.exe $machineName start $service #Start Service
            $errorCode = $LASTEXITCODE
            if($errorCode -eq 1056) {
                Write-Host "Starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: An instance of the service is already running" -foregroundcolor green
                break;
            }
        }
        if($errorCode -eq 0)
        {
            Write-Host "The '$service' service on '$machineName' server started successfully" -foregroundcolor green
        }
        elseif ($errorCode -eq 1053)
        {
            Write-Error "An error occurred in starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service did not respond to the start or control request in a timely fashion"
        }
        elseif ($errorCode -eq 1056)
        {
            Write-Host "An error occurred in starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: An instance of the service is already running"
        }
        elseif ($errorCode -eq 1060)
        {
            Write-Error "An error occurred in starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service"
        }
        elseif ($errorCode -eq 1061)
        {
            Write-Error "An error occurred in starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service cannot accept control messages at this time"
        }
        elseif ($errorCode -eq 1062)
        {
            Write-Host "An error occurred in starting service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service has not been started"
        }
        else
        {
            Write-Error "an error occurred in starting service '$service' on server '$machineName'. errorcode: '$errorCode'"
        }
    }
    if($isRemote -eq 1)
    {
        net use $machineName\IPC$ /delete
    }
}

function StopService()
{
    if($serviceName.Count -ne $processName.Count)
    {
        Write-Error "Invalid parameters. services count does not equal to processes count"
    }
    if($isRemote -eq 1)
    {
      net use $machineName\IPC$ /user:$username $password
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
            
        $errorCode = 999
    
        for($i=0; $i -le $trycount; $i++)
        {
            Write-Host "Service: '$service' i: '$i' trycount: '$trycount' LastExitCode: '$LASTEXITCODE' errorCode: '$errorCode'"
            if($i -ne 0)
            {
                Write-Host "Waiting 5 seconds for stopping service ..."
                Start-Sleep -s $delayBetweenTries
            }
            $result = sc.exe $machineName stop $service #Stop Service
            $errorCode = $LASTEXITCODE
            if($errorCode -eq 0) {
                Write-Host "Stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The operation completed successfully." -foregroundcolor green
                break;
            }
            if($errorCode -eq 1062) {
                Write-Host "Stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service has not been started" -foregroundcolor Yellow
                break;
            }
            if ($errorCode -eq 1060)
            {
                Write-Host "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service" -foregroundcolor Yellow
                break;
            }
        }
        if($errorCode -eq 0)
        {
            Write-Host "The '$service' service on '$machineName' server stopped successfully" -foregroundcolor green
        }
        elseif ($errorCode -eq 1062)
        {
            Write-Host "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service has not been started" -foregroundcolor red
        }
        elseif ($ignoreStopIfNotExists -eq $true and $errorCode -eq 1060)
        {
            Write-Host "An error occurred in stopping service '$service' on server '$server'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service" -foregroundcolor red
        }
        else
        {
            if ($errorCode -eq 1053)
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service did not respond to the start or control request in a timely fashion"
            }
            elseif ($errorCode -eq 1056)
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: An instance of the service is already running"
            }
            elseif ($ignoreStopIfNotExists -eq $false and $errorCode -eq 1060)
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The specified service does not exist as an installed service" -foregroundcolor red
            }
            elseif ($errorCode -eq 1061)
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: The service cannot accept control messages at this time"
            }
            elseif ($errorCode -eq 2242)
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE errormessage: password expired"
            }
            else
            {
                Write-Error "An error occurred in stopping service '$service' on server '$machineName'. errorcode: $LASTEXITCODE"
            }
        }
    }

    if($isRemote -eq 1)
    {
	  #todo kill remote process if exists
      net use $machineName\IPC$ /delete
    }
	else
	{
        #Check process if still running
        $proccessIsRunning = Get-Process $process -ErrorAction silentlycontinue
        if($proccessIsRunning -ne $null)
        {
            for($i=1; $i -le $trycount; $i++)
            {
                Write-Host "Waiting $delayBetweenTries seconds for closing. iteration: $i of $trycount ..."
                Start-Sleep -s $delayBetweenTries

                $proccessIsRunning = Get-Process $process -ErrorAction silentlycontinue
                if($proccessIsRunning -eq $null)
                {
                    break;
                }
                else
                {
                    if($i -eq $trycount)
                    {
                        #Kill process if exists
                        Write-Host "Killing Proccess $process ..."
                        Stop-Process -Name $process
                    }
                }
            }
        }
    }
    return $errorCode;
}

function CreateOrUpdate()
{
    #Check service is installed-if service installed must return 0 (zero) errorcode
    sc.exe query $serviceName
    $errorcode=$LASTEXITCODE
    if($errorcode -ne 1060)#errorcode 1060 yani service nasb nist
    {
        #$stopServiceResult=StopService
        #
        #if($stopServiceResult -eq 0) #Is Stopped
        #{
            if($servicesDependedOn -ne "")
            {
                sc.exe config $serviceName binPath="$binaryPath" start= $startType DisplayName="$serviceDisplayName" depend=$servicesDependedOn
            }
            else
            {
                sc.exe config $serviceName binPath="$binaryPath" start= $startType DisplayName="$serviceDisplayName"
                $error=$LASTEXITCODE
            }
            #if($error -eq 0)
            #{
            #    StartService
            #}  
        #}
    }
    else
    {
        if($servicesDependedOn -ne "")
        {
            sc.exe create $serviceName binPath="$binaryPath" start= $startType DisplayName="$serviceDisplayName" depend=$servicesDependedOn
        }
        else
        {
            sc.exe create $serviceName binPath="$binaryPath" start= $startType DisplayName="$serviceDisplayName"
        }
        $newError=$LASTEXITCODE
    }
}

if($action -eq "start")
{
    StartService
}
elseif($action -eq "stop")
{
    StopService
}
elseif($action -eq "createorupdate")
{
    CreateOrUpdate
} 
else
{
    Write-Error "Action is not defined";
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

#Created by Omid Shariati http://HiDevOps.com http://OmidShariati.com
