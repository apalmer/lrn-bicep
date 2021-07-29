
using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Azure.Identity;
using Azure.Core;
using Microsoft.FeatureManagement;

[assembly: FunctionsStartup(typeof(TestFunctionAlpha.Startup))]

namespace TestFunctionAlpha
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            string endpoint = Environment.GetEnvironmentVariable("AzureAppConfigEndpoint");
            builder.ConfigurationBuilder.AddAzureAppConfiguration(options =>
            {
                var credentials = GetAzureCredentials();

                options.Connect(new Uri(endpoint), credentials);
                options.ConfigureKeyVault(kv => kv.SetCredential(credentials));
                options
                    .Select("gs:*")
                    .ConfigureRefresh(refreshOptions =>
                        refreshOptions.Register("gs:sentinel", refreshAll: true));

                options.UseFeatureFlags();
            });
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
            builder.Services.AddAzureAppConfiguration();
            builder.Services.AddFeatureManagement();
        }

        private static TokenCredential GetAzureCredentials()
        {
            return new DefaultAzureCredential();
        }

    }
}
