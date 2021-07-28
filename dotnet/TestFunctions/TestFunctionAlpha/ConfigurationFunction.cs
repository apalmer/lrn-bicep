using System;
using System.IO;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using Microsoft.Azure.WebJobs;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Newtonsoft.Json;
using Microsoft.Extensions.Configuration;

namespace TestFunctionAlpha
{
    public class ConfigurationFunction
    {
        private readonly IConfiguration _configuration;

        public ConfigurationFunction(IConfiguration configuration)
        {
            _configuration = configuration;
        }

        [FunctionName("GetConfiguration")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            var configValue = _configuration["test:apco:configvalue"];

            string responseMessage = $"Azure App Configuration Value: {configValue}";

            return new OkObjectResult(responseMessage);
        }
    }
}
