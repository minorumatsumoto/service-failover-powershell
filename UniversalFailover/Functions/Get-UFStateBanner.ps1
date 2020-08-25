function Get-UFStateBanner {

<#
.DESCRIPTION
Print the status of the Failover and Service state on other machines

.PARAMETER FailoverConfig
Hashtable configuration used to hold parameter information for service.

.PARAMETER ServerName
Name of the server running this Service

.PARAMETER FailoverState
String that has the state 'Active' or 'Standby'


#>
	
	param(
	
		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[hashtable]$FailoverConfig,

		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$ServerName,

		[parameter(Mandatory = $true)]
		[ValidateSet("Active","Standby")]
		[string]$FailoverState
		
	)
	
	BEGIN {
	
	}#begin
	
	PROCESS {
	
		$ServiceName 	 = $FailoverConfig.Name
		$FailoverCluster = $FailoverConfig.UFConfig
		$Description 	 = $FailoverConfig.Description

		$InitInformationTop = `
		"`n`n===============================================`n" +
		"$Description`n" +
		"===============================================`n`n" +
		"Server (whoami)  `t: $ServerName`n" +
		"Failover Position`t: $FailoverState`n`n"

			# Get Status of all Service Hosts
			foreach ($ServiceHosts in $FailoverCluster.GetEnumerator())
			{
				$ServiceisRunning = get-service -Name $ServiceName -computername $ServiceHosts.name -ErrorAction SilentlyContinue
		
				if (!$ServiceisRunning)
				{
					$serviceState = "No service installed"
				}
				else 
				{
					$serviceState = $ServiceisRunning.Status	
				}
		
				if ((Test-Connection -computer $ServiceHosts.Name -count 1 -quiet))
				{
					$HostServiceState += "Failover Host (online)`t: " + $ServiceHosts.name + "`nService State`t`t: " + $serviceState + "`n`n"
				}
				else
				{
					$HostServiceState += "Failover Host (offline)`t: " + $ServiceHosts.name + "`nService State`t`t: " + $serviceState + "`n`n"
				} 
			}
		
		$InitInformationBottom = `
		"===============================================`n"

		$InitInformationTop
		$HostServiceState
		$InitInformationBottom
		
	}#process
	
	END { }#end
	
	}