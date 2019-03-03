# checkStackReplica
This is a simple linux bash script to verify that all docker services are running with the configured replica number

The script will try 100 times with a sleep of 3 seconds to verify that the actual replica number of each service of the stack is equal to the configured one.

The exit code will be 0 (success) if within the 100 retries times the actual replica numbers will converge to the configured onew. Otherwise the exit code will be 1 (failure)

The script takes as parameter the name of the stack to check

Example:
# ./checkStackReplica.sh mon
