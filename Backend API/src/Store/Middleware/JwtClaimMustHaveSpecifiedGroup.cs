using Microsoft.AspNetCore.Authorization;
using System.Linq;
using System.Threading.Tasks;

namespace Store.Middleware
{
    internal class JwtClaimMustHaveSpecifiedGroup : AuthorizationHandler<JwtGroupMustContainRequirement>
    {
        private const string GroupClaimName = "groups";

        protected override Task HandleRequirementAsync(AuthorizationHandlerContext context,
            JwtGroupMustContainRequirement requirement)
        {
            // First check that claim exists
            if (!context.User.HasClaim(c => c.Type.ToLower() == GroupClaimName))
            {
                return Task.CompletedTask;
            }

            var groups = context.User.FindFirst(c => c.Type.ToLower() == GroupClaimName).Value.Split(",").ToList();
            // Check that its not empty
            if (groups.Count == 0)
            {
                return Task.CompletedTask;
            }

            // Finally, check that the group is in the list
            if (groups.ConvertAll(g => g.ToLower()).Any(requirement.Groups.ConvertAll(g => g.ToLower()).Contains))
            {
                // Mark the requirement as satisfied
                context.Succeed(requirement);
            }

            return Task.CompletedTask;
        }

    }
}
