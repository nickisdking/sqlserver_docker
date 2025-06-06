#!/bin/bash

# Calls SQLCMD to verify that system and user databases return "0" which means all databases are in an "online" state,
# then run the configuration script (setup.sql)
# https://docs.microsoft.com/en-us/sql/relational-databases/system-catalog-views/sys-databases-transact-sql?view=sql-server-2017 

TRIES=60
DBSTATUS=1
ERRCODE=1
i=0

# Use the SA_PASSWORD environment variable
SQL_PASSWORD="${SA_PASSWORD:?SA_PASSWORD environment variable not set}"

while [[ $DBSTATUS -ne 0 ]] && [[ $i -lt $TRIES ]]; do
	i=$((i+1))
	DBSTATUS=$(/opt/mssql-tools18/bin/sqlcmd -h -1 -t 1 -U sa -P "$SQL_PASSWORD" -C -Q "SET NOCOUNT ON; Select COALESCE(SUM(state), 0) from sys.databases") || DBSTATUS=1
	
	sleep 1s
done

if [ $DBSTATUS -ne 0 ]; then 
	echo "SQL Server took more than $TRIES seconds to start up or one or more databases are not in an ONLINE state"
	exit 1
fi

# Run the setup script to create the DB and the schema in the DB
echo "Running configuration script..."

/opt/mssql-tools18/bin/sqlcmd -S localhost -U sa -P "$SQL_PASSWORD" -C -d master -i /tmp/initscripts/setup.sql

echo "Configuration completed."
