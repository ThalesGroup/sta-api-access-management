# Kong Gateway - STA Integration

Kong provides a flexible abstraction layer that securely manages communication between clients and microservices via API.Kong can help by acting as a gateway (or a sidecar) for microservices requests while providing load balancing, logging, authentication, rate-limiting, transformations, and more through plugins.

## Prerequisites
1. A backend API to protect.
2. STA Tenant Access
3. Postman Client

![GitHub Logo](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/Resources/kong-STA.jpg)

## Integration with SafeNet Trusted Access

The OIDC plugin allows us to use Kong as an independent service to manage user sessions. The integration with STA is performed via the ./wellknown discovery endpoints, also you need to create a new Client to allow Kong make request to STA. You'll get more detail about it in the Configuring IdP as an authentication/authorization server section.

When an unauthenticated user request for some resource, Kong redirects to the login page. Once the user is authenticated, Kong will retrieve the session token and generate a session cookie. Depending on the storage type memcache|redis, the cookie may contain some additional information, but we gonna explain this part in the session management section.

## *Session Management*
The OIDC plugin uses the lua-resty-session lib to manage sessions. The session-plugin provided by Kong uses the same open-source library, but is not compatible to work with the opensource OIDC plugin (works only with enterprise plugins). You can configure the session lib using ngnx.conf files, for this case I added some extra parameters to configure the session via oidc plugin.
The lua-resty-session supports multiple storage types, such memcache, redis, shm, cookie, dshm. For this case, I've only added support for cookie and redis, but you can use it as inspiration to implement the other storage types. You can find more information about the available configuration options in the official GitHub repository.

## *Cookie*
This is the default session storage. Once Keycloak authenticates the user, the authorization token is retrieved along with the user scopes. This information is encrypted and send to the client as a cookie. The cookie is flagged HttpOnly by default to avoid javascript manipulation. Depending on the JWT size, the cookie could be bigger than 4kb (max cookie size allowed), so the session lib gonna split the original cookie into little ones (session, session_2, session_3 ...).
Kong doesn't know what's your auth token, so each time you send a request, Kong will decrypt the cookie and get the token, making the web client the only one responsible for the session storage.

## *Redis*
If you want to have total control over the session management, you can store the auth token and other information related with the user session into a redis database. The flows still being the same, the only difference is Kong will return a cookie containing the session identifier to the browser, with no information about the token/user encrypted.
Once you perform requests, Kong will extract the session identifier and retrieves the auth token from the redis storage, setting the Authorization header.

# Configuring IdP as an authentication/authorization server
You can visit to our Kong Gateway Documentation available at [GitHub](http://github.com).

# For Group Based Claim Authorization configuration
If you have already running kong API Gateway opensource setup, you must refer the README.md provided in kong/Plugins folder.

Note: Thales-kong docker image is already updated with the group clamin based authorization changes.
    

