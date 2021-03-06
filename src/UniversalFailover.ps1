<#
.SYNOPSIS
UniversalFailover.ps1 - Give PowerShell scripts Failover capabilities

.DESCRIPTION
Generic wrapper designed to give PowerShell scripts Failover capabilities across x 
number of servers. PowerGUI by quest software can be used to convert this code into 
an installable service that can be executed on multiple servers.

.PARAMETER configurationFile
Hashtable configuration file used to hold parameter information for service. This file should be in
the same directory as the script

.EXAMPLE
UniversalFailover.ps1 .\UFConfig.psd1

.NOTES
Configuration information is held in file UFConfig.psd1 and for best practices should be present in 
the same folder as this source file 

#>

Param
(
    [Parameter(Mandatory=$false)]
    $configurationFile = "./UFConfig.psd1"
)

Import-Module -Name ".\UniversalFailover" -Force

### Configuration ###############################################################################################

$HashtableConfigFile = Import-PowerShellDataFile $configurationFile

### Service Variables
$whoami                     = $env:ComputerName
$ServiceConfiguration		= $HashtableConfigFile.Service
$WaittimeBeforeCheckSeconds = $HashtableConfigFile.Service.PollSeconds

### Main Start #############################################################################################################

$Global:wasInStandByMode = $false

while($true)
{	
	if (Get-UFAvailabilityStatus -FailoverConfig $ServiceConfiguration -ServerName $whoami)
	{
		# Check if server in standby mode previously
		if ($Global:wasInStandByMode)
		{
			# Get Status of all Service Hosts
			Get-UFStateBanner -FailoverConfig $ServiceConfiguration -ServerName $whoami -FailoverState "Active"
			
			$Global:wasInStandByMode = $false
		}

		###########################################################################	
		############################ Put Active code here #########################
		###########################################################################
		
		Write-Host ("....................................")
		start-sleep -seconds $WaittimeBeforeCheckSeconds
	}
	else
	{
		# Server is running in Standby Mode

		if ($Global:wasInStandByMode -eq $false)
        {
            # if not primary or there is a general issue go into standby mode
			Get-UFStateBanner -FailoverConfig $ServiceConfiguration -ServerName $whoami -FailoverState "Standby"
         
            $Global:wasInStandByMode = $true
		}
		
		###########################################################################	
		########################### Put standby code here #########################
		###########################################################################

		Write-Host "Standby Mode ......................."
		start-sleep -seconds $WaittimeBeforeCheckSeconds
	}
}