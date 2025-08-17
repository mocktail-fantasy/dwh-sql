# dwh
data warehouse for mocktail

This repository is CI/CD

All merges will triger execution of all sql files defined by the buildspec.

## DB Connection Instructions
Note: You will need access to the AWS console to obtain necessary values/params.
1) Add bastion host EC2 instance-id as an env variable named: $MOCKTAIL_INSTANCE_ID"
2) Add RDS host name as env variable named: $MOCKTAIL_HOST
3) Run ./scripts/connect-db.sh
4) In SQL IDE of your choosing enter in host: localhost, port: 54320 as well as the database name user name and password. 
5) Connect!