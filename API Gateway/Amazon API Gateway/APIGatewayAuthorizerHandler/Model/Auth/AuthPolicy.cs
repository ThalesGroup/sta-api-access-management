using System.Collections;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace APIGatewayAuthorizerHandler.Model.Auth
{
    public class AuthPolicy
    {
        /// <summary>
        /// The principal ID used for the policy, this should be a unique identifier for the end user.
        /// </summary>
        [JsonProperty(PropertyName = "principalId")]
        public string PrincipalId { get; set; }

        /// <summary>
        /// Comprises the policy version and policy statement.
        /// </summary>
        [JsonProperty(PropertyName = "policyDocument")]
        public PolicyDocument PolicyDocument { get; set; }

        [JsonProperty(PropertyName = "context", NullValueHandling = NullValueHandling.Ignore)]
        public IDictionary<string, object> Context { get; set; } = new Dictionary<string, object>();
    }
}
