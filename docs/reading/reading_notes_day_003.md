# Troubleshooting AWS

## Problem
To configure AWS CLI credentials that will automatically retrieve credentials
from AWS and store it on the local machine we use
```
aws configure sso
```
- we then provide the region and startup url from the AWS identity center
    - A user is created in the identity center and accounts and permission list is 
      attached to that user before hand
- When trying to SSO the system fails silently showing up as a "Server error"
  from the AWS side despite typing in the correct credentials

## Solution
Using arch linux the system was not configured to use the NTP timestamp
as the system clock time 
- ``` sudo timedatectl set-ntp true```
- this makes the system take the datetime from ntp servers
- AWS depends on a correct time stamp from the client side while 
  managing SSO for the AWS CLI
- without this the timestamp will cause failures while authenticating
