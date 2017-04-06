# EE Multiinstaller

The project is a pure extension of Easy Engine functionality to secure shared environment on one server. 

## Usage
```sh
./installer.sh futurelab www.futurelab.co.nz
```
Where first argument is unique Linux username and second your website URL

## Current state
 - We create users and groups and detect if they exist
 - Fail on missing parameters and website duplication

## Todo:
- Create config file
- Create S3 bucket and add all necessary permissions
- Create RDS database and add all necessary permissions
- Add website specific fpm permission (sockets) 
