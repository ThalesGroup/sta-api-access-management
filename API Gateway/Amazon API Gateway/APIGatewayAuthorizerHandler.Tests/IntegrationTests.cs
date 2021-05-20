using System.Linq;
using Amazon.Lambda.TestUtilities;
using APIGatewayAuthorizerHandler.Model;
using Newtonsoft.Json;
using Xunit;

namespace APIGatewayAuthorizerHandler.Tests
{
    public class IntegrationTests
    {
        [Fact]
        public void CallingFunctionWithAnyTokenReturnDenyAllPolicy()
        {
            var function = new Function();
            var request = SampleRequest();
            var lambdaContext = new TestLambdaContext();
            var result = function.FunctionHandler(request, lambdaContext);

            Assert.Equal("f579851a-f570-41d8-a4bc-b9b32c3bb044", result.PrincipalId);
            var firstStatement = result.PolicyDocument.Statement.First();
            Assert.Equal("Allow", firstStatement.Effect);
            Assert.Equal("arn:aws:execute-api:ap-southeast-2:123123123123:123sdfasdf12/prod/*/*", firstStatement.Resource);
        }

        private static TokenAuthorizerContext SampleRequest(string type = "Token", 
            string token = "Bearer eyJhbGciOiJSUzI1NiIsInR5cCIgOiAiSldUIiwia2lkIiA6ICI0Tl94ZUUwSHM0RkJ2UXdINVZNNm0zR0xDVXBoSXEycEF0ME1CWmRrNERJIn0.eyJleHAiOjE2MjA4MzI5MjYsImlhdCI6MTYyMDgzMjYyNiwiYXV0aF90aW1lIjoxNjIwODMyNjI0LCJqdGkiOiIyOTVmOGVmZi1iNzkzLTQyODEtODFjYi01MTFhZjE5OTE1MDkiLCJpc3MiOiJodHRwczovL3NwZWRlbW8tc2FzaWRwLnN0YWRlbW8uY29tL2F1dGgvcmVhbG1zL0tYOE81TEZaRkQtU1RBIiwiYXVkIjoiYjNmMzFiNzQtNTRjZi00OTQwLThkZmQtNzAzZTU2ZGM3MTdkIiwic3ViIjoiMWViNDAxM2QtYmVkNS0zMzFjLWI1ZTctMjkwYTdjZGM2NWM5joiQmVhcmVyIiwiYXpwIzYyIsImFjciI6IjEiLCJhbGxvd2VkLW9yaWdpbnMiOlsiaHR0cHM6Ly9vYXV0aC5wc3Rtbi5pbyJdLCJzY29wZSI6Im9wZW5pZCIsImdyb3VwIjoiZW1wbG95ZWUifQ.MOsd0nTjZfIWmTsJaHEa95hA-VUc1dO5EeU-yL6TwJSv6mqmr1CX4ibTO0grR40vxevdQXVFy3t0IPFUZvn6DMAYX3JMtaV6ayrpr_BUwn7sdmakfzENZoa_w8tfWtx-kqCA_y8MD_P5QnmaEmagSPWs1kyQHoFUXS59PNZkk-JYvuAnW9jM-4ARr_LBHaNY893Vk3iKiiRKu5_GnNCpDAT6XnnJ0pLpvaGwx23BmI4nbIML4hcuhJw9GKSR4Ww5CGN5-FNcUWzVFooAcSHzulik_fuSxt2_E7RFafCxiIznY4IDMCoi-zIyGY7-SiwHEiBG4SoE66hPoyL4t5CyLg",
            string region = "ap-southeast-2",
            string accoundId = "123123123123",
            string restApiId = "123sdfasdf12",
            string stage = "prod",
            string verb = "GET")
        {
            string json = $@"{{ ""Type"": ""{type}"", ""AuthorizationToken"": ""{token}"", ""MethodArn"": ""arn:aws:execute-api:{region}:{accoundId}:{restApiId}/{stage}/{verb}/"" }}";
            return JsonConvert.DeserializeObject<TokenAuthorizerContext>(json);
        }
    }
}
