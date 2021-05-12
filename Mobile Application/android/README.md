# Description

This is the API Protection demo Android application. This app demonstrates how
Thales API Gateway can protect API services from malicious users, by providing
an API gateway that protects a sample retail API

This app has no concept of what APIs are protected, and uses OAuth credentials
to access these APIs with whatever credentials have been provided. 

### Build Environment

This has been tested to build from Mac OS Mojave, but should build in any 
environment withJava 1.8 and the Android SDK installed.

### Build Instructions

This app utilizes gradle to build. 
Below are the different target you might want to build

_Release Variant_
`./gradlew assembleRelease`

_Debug Variant_
`./gradlew assembleDebug`

### Configuration
The server configuration is defaulted to an empty configuration. You can find 
this in the MainActivity.kt class.
Alternatively, you can provide a schema to the app after the user has launched 
it through file sharing

The schema can be seen below
~~~~
{
   "apiUrl":"https://back.end.api/",
   "publicClientId":"client_credential_id",
   "publicClientSecret":"client_credential_secret",
   "publicClientWellknown":"https://{client-credential-hostname}/.well-known/openid-configuration",
   "retailClientId":"authorization_id",
   "retailClientSecret":"authorization_secret",
   "retailClientWellknown":"https://{authorization-hostname}/.well-known/openid-configuration"
}
~~~~
