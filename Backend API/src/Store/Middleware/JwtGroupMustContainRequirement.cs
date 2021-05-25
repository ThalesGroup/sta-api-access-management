using Microsoft.AspNetCore.Authorization;
using System.Collections.Generic;

namespace Store.Middleware
{
    internal class JwtGroupMustContainRequirement : IAuthorizationRequirement
    {
        public JwtGroupMustContainRequirement(List<string> groups)
        {
            Groups = groups;
        }

        public List<string> Groups { get; }
    }

}
