#!/bin/bash
aws ssm start-session --target "$MOCKTAIL_INSTANCE_ID" \
--document-name "AWS-StartPortForwardingSessionToRemoteHost" \
--parameters "{\"host\":[\"$MOCKTAIL_HOST\"],\"portNumber\":[\"5432\"],\"localPortNumber\":[\"54320\"]}" --region us-east-1 --profile cdk-mocktail