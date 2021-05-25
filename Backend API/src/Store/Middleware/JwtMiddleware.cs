using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.IdentityModel.Protocols;
using Microsoft.IdentityModel.Protocols.OpenIdConnect;
using Microsoft.IdentityModel.Tokens;
using Newtonsoft.Json;
using System.Collections.Generic;
using System.Threading;
using System.Threading.Tasks;

namespace Store.Middleware
{
    namespace WebApi.Middleware
    {
        /// <summary>
        /// Class used to setup the Authentication Validation parameters as well
        /// as the Authorization policies
        /// </summary>
        public static class JwtMiddleware
        {
            private const string ManagerGroup = "manager";
            private const string EmployeeGroup = "employee";
            /// <summary>
            /// Used to define the JwtClaimMustContainManagerPolicy so it can be used globaly instead of
            /// using magic strings
            /// </summary>
            public const string JwtClaimMustContainManagerPolicy = "JwtClaimMustContainManager";
            /// <summary>
            /// Used to define the JwtClaimMustContainManagerOrEmployeePolicy so it can be used globaly instead of
            /// using magic strings
            /// </summary>
            public const string JwtClaimMustContainManagerOrEmployeePolicy = "JwtClaimMustContainManagerOrEmployee";

            /// <summary>
            /// 
            /// </summary>
            /// <param name="services"></param>
            /// <param name="configuration"></param>
            /// <returns></returns>
            public static void AddJwtAuthorizationAndAuthentication(this IServiceCollection services, IConfiguration configuration)
            {
                // if JwtAuthorizationAndAuthenticationEnabled is false then do not do any of the below code and return immediately
                var authority = configuration["JwtAuthentication:Authority"] ?? string.Empty;
                var openIdConfig = new OpenIdConnectConfiguration();

                // if either the authority is not defined or JwtValidationAndAuthentication is false then do not
                // attempt to retrieve the Keys
                if (!string.IsNullOrWhiteSpace(authority) &&
                    bool.Parse(configuration["JwtAuthorizationAndAuthenticationEnabled"] ?? "false"))
                {
                    IConfigurationManager<OpenIdConnectConfiguration> configurationManager =
                        new ConfigurationManager<OpenIdConnectConfiguration>(
                            $"{authority}",
                            new OpenIdConnectConfigurationRetriever());
                    openIdConfig =
                        configurationManager.GetConfigurationAsync(CancellationToken.None).Result;
                }

                var tokenValidationParameters = new TokenValidationParameters

                {
                    ValidateIssuerSigningKey = true,
                    ValidateIssuer = bool.Parse(configuration["JwtAuthentication:ValidateIssuer"] ?? "true"),
                    ValidateAudience = bool.Parse(configuration["JwtAuthentication:ValidateAudience"] ?? "true"),
                    ValidAudience = configuration["JwtAuthentication:ClientId"],
                    ValidIssuer = configuration["JwtAuthentication:Issuer"],
                    IssuerSigningKeys = openIdConfig?.SigningKeys
                };

                // Authentication is validating that the JWT has a valid signature
                // and that it has not expired.
                services.AddAuthentication("Bearer").AddJwtBearer(options =>
                {
                    options.TokenValidationParameters = tokenValidationParameters;
                    
                    options.Events = new JwtBearerEvents
                    {
                        OnForbidden = context =>
                        {
                            // This happens when a policy is not satisfied
                            var message =
                                "Unauthorized. You need to login as an employee or manager to execute this function.";
                            context?.Response.OnStarting(async () =>
                                {
                                    context.Response.ContentType = "application/json; charset=utf-8";
                                    var result = JsonConvert.SerializeObject(new { message });

                                    await context.Response.WriteAsync(result);
                                });
                            

                            return Task.CompletedTask;
                        },
                        OnAuthenticationFailed = context =>
                        {
                            // This happens on any exception, including the JWT being tampered with
                            var message =
                                "Unauthorized. You need to login as an employee or manager to list warehouses";
                            if (context?.Exception == null)
                            { 
                                context?.Response.OnStarting(async () =>
                                {
                                    context.Response.ContentType = "application/json; charset=utf-8";
                                    var result = JsonConvert.SerializeObject(new {message});

                                    await context.Response.WriteAsync(result);
                                });
                            }

                            return Task.CompletedTask;
                        },
                        OnChallenge = context =>
                        {
                            // this happens when the signature is invalid, or when the token has expired
                            var message =
                                "Unauthorized. You need to login as an employee or manager to list warehouses";

                            if (context?.ErrorDescription != null &&
                                    context.ErrorDescription.Contains("token expired"))
                                {
                                    message = "Unauthorized. Token Expired.";
                                }

                                context?.Response.OnStarting(async () =>
                                {
                                    context.Response.ContentType = "application/json; charset=utf-8";
                                    var result = JsonConvert.SerializeObject(new {message});

                                    await context.Response.WriteAsync(result);
                                });
                            
                            return Task.CompletedTask;
                        }
                    };
                });

                // Authorization is then verifying that the token has claims etc that
                // match defined policies
                services.AddAuthorization(options =>
                {
                    //Add Authorization Policies Here
                    options.AddPolicy(JwtClaimMustContainManagerPolicy,
                        policy => policy.Requirements.Add(
                            new JwtGroupMustContainRequirement(new List<string> {ManagerGroup})));

                    options.AddPolicy(JwtClaimMustContainManagerOrEmployeePolicy,
                        policy => policy.Requirements.Add(
                            new JwtGroupMustContainRequirement(new List<string> {ManagerGroup, EmployeeGroup})));

                    options.InvokeHandlersAfterFailure = false;
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            }
        }
    }
}
