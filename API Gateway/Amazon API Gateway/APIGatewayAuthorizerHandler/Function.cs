using System;
using System.Collections.Generic;
using Amazon.Lambda.Core;
using APIGatewayAuthorizerHandler.AccessTokenValidation;
using APIGatewayAuthorizerHandler.Model;
using APIGatewayAuthorizerHandler.Model.Auth;

namespace APIGatewayAuthorizerHandler
{
    public class Function
    {
        /// <summary>
        /// A function that acts an entry point, takes the token authorizer, and returns a policy based on the supplied token.
        /// </summary>
        /// <param name="input">The token authorization received by the api-gateway event sources</param>
        /// <param name="context"></param>
        /// <returns>IAM Auth Policy</returns>
        [LambdaSerializer(typeof(Amazon.Lambda.Serialization.Json.JsonSerializer))]
        public AuthPolicy FunctionHandler(TokenAuthorizerContext input, ILambdaContext context)
        {
            try
            {
                context.Logger.LogLine($"{nameof(input.AuthorizationToken)}: {input.AuthorizationToken}");
                context.Logger.LogLine($"{nameof(input.MethodArn)}: {input.MethodArn}");

                var tokenValidation = new TokenValidation(context);
                var principalId = tokenValidation.GetPrincipalId(input.AuthorizationToken);

                var methodArn = ApiGatewayArn.Parse(input.MethodArn);
                var apiOptions = new ApiOptions(methodArn.Region, methodArn.RestApiId, methodArn.Stage);

                var policyBuilder = new AuthPolicyBuilder(principalId, methodArn.AwsAccountId, apiOptions);

                // Add your API endpoints and their corresponding HTTP verb, that does not require Group authorization
                policyBuilder.AllowMethod(HttpVerb.Get, "/shop");
                policyBuilder.AllowMethod(HttpVerb.Get, "/shop/*");
                policyBuilder.AllowMethod(HttpVerb.Get, "/shop/*/products");
                policyBuilder.AllowMethod(HttpVerb.Get, "/shop/*/stock");
                policyBuilder.AllowMethod(HttpVerb.Post, "/reset");

                var groupName = tokenValidation.GroupName;

                if (groupName == null)
                {
                    context.Logger.LogLine("No group based authorization needed");
                }
                else
                {
                    // Replace the "employee" and "manager" group names below with your preferred choice
                    // Add your API endpoints and their corresponding HTTP verb, that requires Group authorization
                    if (groupName.Contains(','))
                    {
                        var groups = new List<string>(groupName.Split(','));
                        if (groups.Contains("employee") && groups.Contains("manager"))
                        {
                            policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse");
                            policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*");
                            policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*/stock");
                            policyBuilder.AllowMethod(HttpVerb.Post, "/warehouse/*/stock/*/move/*");
                        }
                        else
                        {
                            context.Logger.LogLine("Group based authorization failed");
                        }
                    }
                    else if (groupName == "employee" || groupName == "manager")
                    {
                        switch (groupName)
                        {
                            case "employee":
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse");
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*");
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*/stock");
                                break;

                            case "manager":
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse");
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*");
                                policyBuilder.AllowMethod(HttpVerb.Get, "/warehouse/*/stock");
                                policyBuilder.AllowMethod(HttpVerb.Post, "/warehouse/*/stock/*/move/*");
                                break;
                        }
                    }
                    else
                    {
                        context.Logger.LogLine("Group based authorization failed");
                    }
                }

                var authResponse = policyBuilder.Build();
                authResponse.Context.Add("key", "value");
                authResponse.Context.Add("number", 1);
                authResponse.Context.Add("bool", true);

                return authResponse;
            }
            catch (Exception ex)
            {
                context.Logger.LogLine(ex.ToString());
                throw new Exception("Unauthorized");
            }
        }
    }
}
