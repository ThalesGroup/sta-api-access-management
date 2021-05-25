
## Table of contents
 * [Store - ASP.NET Core 3.1 Server](#Store-ASP.NET-Core-3.1-Server)
 * [Configuration](#configuration)
 * [Sample Code](#sample-code)
	 * [Middleware](#middleware)
	 * [Defining Authorization and Authentication in the API](#defining-authorization-and-authentication-in-the-api)
 * [Run](#run)
 * [Run in Docker](#run-in-docker)
 * [View Swagger](#view-swagger)

# Store - ASP.NET Core 3.1 Server

This is a simple store API with authentication and authorization.

The sample code demonstrates how to enable authentication and authorization on a sample Swagger API. Enabling authentication ensures that a JWT is valid. For example, a valid JWT has not been tampered with and has not expired. Enabling authorization checks that the JWT has specific claims when a JWT is used.

## Configuration

When debugging in the web profile, the src/Store/appsettings.json file is used to define the settings.

When debugging in the Docker profile, the src/Store/Properties/launchSettings.json is used to define the settings.

By default, the sample code does not have Authorization and Authentication turned on. If the `JwtAuthorizationAndAuthenticationEnabled` is true, the `Authority` must also be set, otherwise the application will not start.

If `ValidateIssuer` is set to true, the `Issuer` must have a valid value otherwise the JWT Authorization will always fail.

If `ValidateAudience` is set to true, the `ClientId` must be a valid value otherwise the JWT Authorization will always fail.

|Setting|Value  |Default|
|--|--|--|
|JwtAuthorizationAndAuthenticationEnabled| If true, enables authentication and authorization| false
|ValidateIssuer| If true, ensures that the Issuer (iss) in the JWT is validated| true
|Issuer|If ValidateIssuer is true, then the JWT issuer must match this property||
|ValidateAudience| If true, ensures that the Audience (aud) of the JWT is validated| true
|ClientId| If ValidateAudience is true, then the JWT audience must match this property||
|Authority| The well-known openid-configuration URL where the JWT public key is defined. It is used to validate that the token has not been tampered with||


## Sample Code

### Middleware
The code in src/Store/Middleware/ defines both the authorization and authentication.

The JwtMiddleware is injected in Startup.cs by calling `services.AddJwtAuthorizationAndAuthentication(Configuration)`

In this method, we define how the JWT is authenticated (using the `TokenValidationParameters`).

The response body is also defined, depending on the JWT events. 

Authorization is defined in policies. In this sample code, two policies are defined:

- `JwtClaimMustContainManager` checks that the JWT has a claim called `groups` and that it must have `manager` in the claim.
-   `JwtClaimMustContainManagerOrEmployee` defines that the JWT must have either `manager` or `employee` in the `groups` claim.

If any of this is not true, the response to the request is Unauthorized.

The implementation details for the policy can be found in the `JwtClaimMustHaveSpecifiedGroup` class.

### Defining Authorization and Authentication in the API
Methods that need only authorization, which is verification that the JWT has not been tampered with and has not expired, have the `[Authorize]` decorator.

Methods that need both authorization and authentication that the token has `manager` or `employee` in the `groups` claim have the `[Authorize(Policy = JwtClaimMustContainManagerOrEmployee)]` decorator.

Methods that need both authorization and authentication that the token has `manager`  in the `groups` claim have the `[Authorize(Policy = JwtClaimMustContainManager)]` decorator.


## Run

Linux/OS X:

```
sh build.sh
```

Windows:

```
build.bat
```

## Run in Docker

```
docker build -t store .
docker run -p 8080:8080 store
```

## View Swagger
```
http://localhost:8080/swagger
```
