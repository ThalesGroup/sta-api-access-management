using System;
using Microsoft.IdentityModel.Tokens;
using System.IdentityModel.Tokens.Jwt;
using System.IO;
using System.Linq;
using System.Net.Http;
using System.Security.Claims;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using Amazon.Lambda.Core;

namespace APIGatewayAuthorizerHandler.AccessTokenValidation
{
    public class TokenValidation
    {
        private JsonWebKey _signingKey;
        public string GroupName => _groupName;
        private string _issuer;
        private string _jwksUrl;
        private string _wellKnownConfigurationUrl;
        private string _groupName;
        private const string _configFilePath = "config.json";

        public TokenValidation(ILambdaContext context)
        {
            GetWellKnownConfigurationUrl();
            GetIssuerAndJwksUrl(context);
            GetSigningKey(context);
        }

        private ClaimsPrincipal GetClaimsPrincipal(string authToken)
        {
            var validationParameters = GetValidationParameters();
            var splittedAuthToken = authToken.Split(" ");
            var jwtSecurityTokenHandler = new JwtSecurityTokenHandler();

            return jwtSecurityTokenHandler.ValidateToken(splittedAuthToken[1], validationParameters, out _);
        }

        public string GetPrincipalId(string authToken)
        {
            var claimsPrincipal = GetClaimsPrincipal(authToken);
            _groupName = claimsPrincipal.Claims.FirstOrDefault(c => c.Type == "http://schemas.xmlsoap.org/claims/Group")?.Value;

            return claimsPrincipal.Claims.FirstOrDefault(c => c.Type == ClaimTypes.NameIdentifier)?.Value;
        }

        private void GetWellKnownConfigurationUrl()
        {
            var path = Path.Combine(Directory.GetCurrentDirectory(), _configFilePath);

            using (var reader = new JsonTextReader(File.OpenText(path)))
            {
                var jsonObject = (JObject)JToken.ReadFrom(reader);
                _wellKnownConfigurationUrl = jsonObject["wellKnownConfigurationUrl"].ToString();
            }
        }

        private async void GetIssuerAndJwksUrl(ILambdaContext context)
        {
            var client = new HttpClient();
            var response = client.GetAsync(_wellKnownConfigurationUrl).Result;
            if (response.IsSuccessStatusCode)
            {
                var wellKnownData = await response.Content.ReadAsStringAsync();
                if (string.IsNullOrEmpty(wellKnownData))
                {
                    context.Logger.LogLine("Unable to fetch Well Known Configuration data");
                }
                else
                {
                    var jsonObject = (JObject)JToken.Parse(wellKnownData);
                    _issuer = jsonObject["issuer"].ToString();
                    _jwksUrl = jsonObject["jwks_uri"].ToString();
                }
            }
            else
            {
                context.Logger.LogLine("HTTP connection with WellKnownConfigurationUrl is not successful");
            }
        }

        private async void GetSigningKey(ILambdaContext context)
        {
            var client = new HttpClient();
            var response = client.GetAsync(_jwksUrl).Result;
            if (response.IsSuccessStatusCode)
            {
                var certificateDetails = await response.Content.ReadAsStringAsync();
                var jwks = new JsonWebKeySet(certificateDetails);
                _signingKey = jwks.Keys.FirstOrDefault();
            }
            else
            {
                context.Logger.LogLine("HTTP connection with JWKSUrl is not successful");
            }
        }

        private TokenValidationParameters GetValidationParameters()
        {
            return new TokenValidationParameters
            {
                ValidIssuer = _issuer,
                ValidateIssuer = true,
                ValidateAudience = false,
                ValidateIssuerSigningKey = true,
                IssuerSigningKey = _signingKey
            };
        }
    }
}