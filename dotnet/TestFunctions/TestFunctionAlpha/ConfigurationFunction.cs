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
using System.Linq;
using Microsoft.Extensions.Configuration.AzureAppConfiguration;
using Microsoft.FeatureManagement;

namespace TestFunctionAlpha
{
    public class ConfigurationFunction
    {
        private readonly IConfiguration _configuration;
        private readonly IConfigurationRefresher _configurationRefresher;
        private readonly IFeatureManagerSnapshot _featureManagerSnapshot;

        public ConfigurationFunction(IConfiguration configuration, IConfigurationRefresherProvider refresherProvider, IFeatureManagerSnapshot featureManagerSnapshot)
        {
            _configuration = configuration;
            _configurationRefresher = refresherProvider.Refreshers.First();
            _featureManagerSnapshot = featureManagerSnapshot;
        }

        [FunctionName("GetConfiguration")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Function, "get", Route = null)] HttpRequest req,
            ILogger log)
        {
            log.LogInformation("C# HTTP trigger function processed a request.");

            await _configurationRefresher.TryRefreshAsync();

            var configValue = _configuration["gs:configvalue"];
            var keyVaultRefValue = _configuration["gs:keyvaultref"];

            string responseMessage = $"Azure App Configuration Value: {configValue}\n";
            responseMessage += $"Key Vault Reference Value: {keyVaultRefValue}\n";

            if(await _featureManagerSnapshot.IsEnabledAsync("gs-feature-flag"))
            {
                responseMessage += "Feature Alpha Enabled\n";
            }

            return new OkObjectResult(responseMessage);
        }
    }
}
