using System;
using System.Collections.Generic;
using System.Security.Claims;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.VisualStudio.TestTools.UnitTesting;
using Microsoft.Extensions.DependencyInjection;
using Store.Middleware;

namespace StoreTests
{
    [TestClass]
    public class TestAuthorizationPolicy
    {
        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationSucceeds_When_ClaimContainsGroup()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> {"manager", "employee"})));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("groups", "manager") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsTrue(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationFails_When_ClaimDoesNotContainsGroup()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> { "manager", "employee" })));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("groups", "anotherrole") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsFalse(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationSucceeds_When_ClaimContainsGroupClaimWithMultipleGroups()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> { "manager", "employee" })));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("groups", "anotherrole,employee") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsTrue(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationFails_When_ClaimDoesNotContainGroupClaim()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> { "manager", "employee" })));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("anotherclaim", "anotherrole,employee") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsFalse(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationFails_When_ClaimContainsGroupClaimButClaimIsEmpty()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> { "manager", "employee" })));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("groups", "") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsFalse(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        [TestMethod]
        public void JwtClaimMustContainSpecifiedGroup_AuthenticationSucceeds_When_ClaimContainsGroupClaimClaimsAreCaseInsensitive()
        {
            var authorizationService = BuildAuthorizationService(services =>
            {
                services.AddAuthorizationCore(options =>
                {
                    options.AddPolicy("SomePolicyName", policy => policy.Requirements.Add(
                        new JwtGroupMustContainRequirement(new List<string> { "manager", "Employee" })));
                });
                services.AddSingleton<IAuthorizationHandler, JwtClaimMustHaveSpecifiedGroup>();
            });
            var user = new ClaimsPrincipal(new ClaimsIdentity(
                new[] { new Claim("groups", "employee,Manager") }));

            Task.Run(async () =>
            {
                var allowed = await authorizationService.AuthorizeAsync(user, "SomePolicyName");
                // Assert
                Assert.IsTrue(allowed.Succeeded);
            }).GetAwaiter().GetResult();

        }

        private IAuthorizationService BuildAuthorizationService(
            Action<IServiceCollection> setupServices = null)
        {
            var services = new ServiceCollection();
            services.AddAuthorization();
            services.AddLogging();
            services.AddOptions();
            setupServices?.Invoke(services);
            return services.BuildServiceProvider().GetRequiredService<IAuthorizationService>();
        }
    }
}
