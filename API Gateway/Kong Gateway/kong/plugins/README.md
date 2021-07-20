# Group Claim Based Authorization Configuration

```
Note: If your are installing Thales-Kong Image to deploy kong setup, then you are not required to perform the below settings.
However, if kong Opensource is already installed in your environment, then only perform the below setting for group claim based authorizaton.
```

If you need to apply authorization while authenticating REST API you need to perform following changes

1. To enter into kong container, run the following command
    **docker exec -it --user=root** <**kong Container name**> **sh**

   where, **kong_container_name** is the container name that you used to deployed your kong OSS container.

   You can verify kong container name using **docker ps** command.

2. Then , go to **/usr/local/share/lua/5.1/kong/plugins/oidc** folder,Open schema.lua file using **vi schema.lua** command.

3. Under fields = {} section , Add the two lines in the end,as mentioned below:
   
    **groups_claim_required= { type = "boolean", required = false, default = false },**
   
    **group_claim = { type = "string", required = false, default = "" }**

4. Save the changes.

5. From current directory,Open **Utils.lua** file using **vi utils.lua** command.

6. Scroll down and Under **M.get_option funtions** ,Add the two lines in the end ,as mentioned below:
    
      **group_claim = config.group_claim,**
      
      **groups_claim_required = config.groups_claim_required,**

7. Save the changes.

8. Then, go to folder **/usr/local/openresty/lualib/resty**, Open **Openidc.lua** file using **vi openidc.lua**

## For Web browser Flow

a. You need to change the following:
 
 Search for **check audience (array or string)** section in this file and add the below code snippet section after it:

    ```
     -- Handling group authorization use case for web browser.
      if opts.groups_claim_required then
        if (string.find(id_token.group, opts.group_claim)== nil) then
          log(ERROR, "group name mismatch in id_token")
          return false
        end
      end 
     ```
 ![Web-browser.png](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/kong/lib/resty/Resources/web-browser.png)
 
 ## For Postman-Client Flow
 
 a. Search for **if not json.active then** section in this file and modify the code snippet as mentioned below:

    ```
     -- Handling invalid token with customized message. 
        if not json.active then
          err = "invalid token"
          return kong.response.exit(401, "Invalid Access Token")
        end
     ```
     
 ![Web-browser.png](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/kong/lib/resty/Resources/postman-invalid_token.png)
 
  b. Search for **if not introspection_cache_ignore and json[expiry_claim] then** section in this file and add the below code snippet after end of this loop:

    ```
      -- Handling group authorization use case with customized message.
          if opts.groups_claim_required then
            if (json.group == nil || opts.group_claim == nil) then
              return kong.response.exit(400, "Bad request/response.")
            elseif (string.find(json.group, opts.group_claim)== nil) then
              err = "group name mismatch in id_token"
              return kong.response.exit(403, "Access Forbidden")
            end
          end
          return json, err
     ```
![Web-browser.png](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/kong/lib/resty/Resources/postman-group%20claim%20and%20msg.png)

  c. Search for **local access_token, err = openidc_get_bearer_access_token(opts)** section in this file and modify the code snippet as mentioned below:
   
     ```
        -- Handling empty access token use case in request with customize message.
            local access_token, err = openidc_get_bearer_access_token(opts)
            if access_token == nil then
              return kong.response.exit(400, "Bad Request")
            end

       ```

![Web-browser.png](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/kong/lib/resty/Resources/postman-Nogroupclaim.png)

  d. Search for **function openidc.bearer_jwt_verify(opts, ...)** section in this file and modify the code snippet as mentioned below before this function:
   
     ```
        -- Handling token expiration use case with customized message.
            if json then
              if json.exp and json.exp + slack < ngx.time() then
                log(ERROR, "token expired: json.exp=", json.exp, ", ngx.time()=", ngx.time())
                err = "JWT expired"
              return kong.response.exit(401, "Unauthorised Access")
              end
            end

            return json, err
          end
       ```
![Web-browser.png](https://github.com/ThalesGroup/sta-api-access-management/blob/master/API%20Gateway/Kong%20Gateway/kong/lib/resty/Resources/postman-JWTExpired%20msg.png)

e. Save the changes.
