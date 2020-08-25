function Get-UFAvailabilityStatus {

<#
.DESCRIPTION
Returns $true if this servers service is seen as Active (Primary).

.PARAMETER FailoverConfig
Hashtable configuration used to hold parameter information for service.

.PARAMETER ServerName
Name of the server running this Service

#>	

	param(

		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[hashtable]$FailoverConfig,

		[parameter(Mandatory = $true)]
		[ValidateNotNullOrEmpty()]
		[string]$ServerName	
	)

	BEGIN {

	}#begin

	PROCESS {

		$ExecuteStatus = $true
	
		$ServiceName 	 = $FailoverConfig.Name
		$FailoverCluster = $FailoverConfig.UFConfig

		# Get This Servers Redundancy Position. 
		# If Server is at position 0 (Primary) execute script 
		if ([int]$FailoverCluster.$ServerName -ne 0)
		{
			# If not highest priority, For each server in the list
			foreach ($server in $FailoverCluster.GetEnumerator())
			{
				# Ensure we are not looking at this server
				if ($server.name -ne $ServerName)
				{
					# Check if Server is reachable
					if (Test-Connection -computer $server.name -count 1 -quiet)
					{ 
						# Check if the Service on that computer is running
						$ServiceisRunning = get-service -Name $ServiceName -computername $server.name -ErrorAction SilentlyContinue
						
						If ($ServiceisRunning.Status -eq "Running")
						{
							# Check if this server is in a higher position than the one being tested
							if ([int]$FailoverCluster.$ServerName -gt [int]$server.value)
							{
								# If higher, this server can't execute the script, as a more suitable
								# Server is online and will take over.
								$ExecuteStatus = $false
								break;
							}
						}
					} 
				}
			}
		}
		
		return $ExecuteStatus

	}#process

	END { }#end

}


