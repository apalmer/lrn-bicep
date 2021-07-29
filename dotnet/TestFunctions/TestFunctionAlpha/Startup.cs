
using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Azure.Identity;
<<<<<<< HEAD
=======
using Azure.Core;
using Microsoft.FeatureManagement;
>>>>>>> master

[assembly: FunctionsStartup(typeof(TestFunctionAlpha.Startup))]

namespace TestFunctionAlpha
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
<<<<<<< HEAD
            string endpoint = Environment.GetEnvironmentVariable("AzureAppConfiguration:Endpoint");
            builder.ConfigurationBuilder.AddAzureAppConfiguration(options=> 
            {
                options
                    .Connect(new Uri(endpoint), new DefaultAzureCredential())
                    .ConfigureKeyVault(kv =>
                    {
                        kv.SetCredential(new DefaultAzureCredential());
                    });
=======
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
>>>>>>> master
            });
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
<<<<<<< HEAD
        }
=======
            builder.Services.AddAzureAppConfiguration();
            builder.Services.AddFeatureManagement();
        }

        private static TokenCredential GetAzureCredentials()
        {
            return new DefaultAzureCredential();
        }

>>>>>>> master
    }
}
