# Description

This is the API Access Management application demo for iOS. This app demonstrates how
Thales API Gateway can protect API services from unauthorized users, by providing
an API gateway that protects a sample retail API.

This app has no concept of what APIs are protected, and uses OAuth credentials
to access these APIs with whatever credentials have been provided. 

### Build Environment

This has been tested to build from Mac OS Catalina, with Xcode 12.4.
iOS 14.4 and above is required to run the app. 

### Build Instructions

Open the project using Xcode 12.4.
Build the app on Simulator / Device target as you normally would 
with any iOS project.

The project has dependency with [https://github.com/openid/AppAuth-iOS] using
Swift Package Manager. This dependency is resolved automatically during build 
as long as there is connection to github. 

### Configuration
The server configuration is set to a generic configuration by default. In order to properly 
run the app, a valid server configuration file in JSON format needs to be imported.

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
Before running the app, make sure you have saved a valid JSON config file on your device. At the app's first launch, 
it will require a config file which can be done by using the file selector displayed after tapping the `Import` button.  
