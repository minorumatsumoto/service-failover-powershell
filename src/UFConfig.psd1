@{

    Service = @{

        # Description of the service to be failed over
        Description = 'Universal Failover for Service'

        # Name of the service to monitor
        Name = "ServiceName"

        # Number of seconds before each Service Poll
        PollSeconds  = 60

        # Host failover positon and Server name 
        UFConfig = @{

            "SERVER01"  = "0";
            "SERVER02"  = "1"

        } # End of ServiceHost hashtable

    } # End of ServiceConfig hashtable

}