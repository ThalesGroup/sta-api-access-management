using Newtonsoft.Json;

namespace APIGatewayAuthorizerHandler.Model
{
    public class TokenAuthorizerContext
    {
        /// <summary>
        /// The type property specifies the authorizer type. Supported values are TOKEN and REQUEST.
        /// </summary>
        [JsonProperty(PropertyName = "Type")]
        public string Type { get; set; }

        /// <summary>
        /// It contains the caller-supplied token.
        /// </summary>
        [JsonProperty(PropertyName = "AuthorizationToken")]
        public string AuthorizationToken { get; set; }

        /// <summary>
        /// The methodArn is the Amazon Resource Name (ARN) of the incoming method request.
        /// </summary>
        [JsonProperty(PropertyName = "MethodArn")]
        public string MethodArn { get; set; }
    }
}
