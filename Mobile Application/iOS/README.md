# Description

This is the API Access Management applciation demo for iOS. This app demonstrates how
Thales API Gateway can protect API services from unauthorized users, by providing
an API gateway that protects a sample retail API

This app has no concept of what APIs are protected, and uses OAuth credentials
to access these APIs with whatever credentials have been provided. 

### Build Environment

This has been tested to build from Mac OS Catalina, with Xcode 12.4. 

### Build Instructions

Open the project using Xcode 12.4.
Build the app on Simulator / Device target as you normally would 
with any iOS project.

The project has dependency with [https://github.com/openid/AppAuth-iOS] using
Swift Package Manager. This dependency is resolved automatically during build 
as long as there is connection to github. 

### Configuration
The server configuration is defaulted to the AWS configuration. You can find
this at `ApiAccessManagementDemo/Resources/Json/Config.json`.

The schema can be seen below
```
{
   "apiUrl":"https://back.end.api/",
   "publicClientId":"client_credential_id",
   "publicClientSecret":"client_credential_secret",
   "publicClientWellknown":"https://{client-credential-hostname}/.well-known/openid-configuration",
   "retailClientId":"authorization_id",
   "retailClientSecret":"authorization_secret",
   "retailClientWellknown":"https://{authorization-hostname}/.well-known/openid-configuration"
}
```
