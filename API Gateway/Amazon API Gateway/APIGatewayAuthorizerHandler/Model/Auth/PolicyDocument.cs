using Newtonsoft.Json;
using System.Collections.Generic;

namespace APIGatewayAuthorizerHandler.Model.Auth
{
    public class PolicyDocument
    {
        /// <summary>
        /// The policy version used for the evaluation. This should always be "2012-10-17".
        /// </summary>
        [JsonProperty(PropertyName = "Version")]
        public string Version { get; set; }

        /// <summary>
        /// It comprises the Effect, Action, and Resource.
        /// </summary>
        [JsonProperty(PropertyName = "Statement")]
        public IEnumerable<Statement> Statement { get; set; }
    }
}
