using Newtonsoft.Json;
using System.Collections.Generic;

namespace APIGatewayAuthorizerHandler.Model.Auth
{
    public class Statement
    {
        /// <summary>
        /// It represents an API-executing action. Supported options are *, Invoke, and InvalidateCache.
        /// </summary>
        [JsonProperty(PropertyName = "Action")]
        public string Action { get; set; }

        /// <summary>
        /// It represents permission. Supported options are Allow and Deny.
        /// Default to Deny to ensure that Allow is explicitly set.
        /// </summary>
        [JsonProperty(PropertyName = "Effect")]
        public string Effect { get; set; } = "Deny";

        /// <summary>
        /// It represents an API endpoint that you want to allow or deny access.
        /// </summary>
        [JsonProperty(PropertyName = "Resource")]
        public string Resource { get; set; }

        [JsonProperty(NullValueHandling = NullValueHandling.Ignore)]
        public IDictionary<ConditionOperator, IDictionary<ConditionKey, string>> Condition { get; set; }
    }
}
