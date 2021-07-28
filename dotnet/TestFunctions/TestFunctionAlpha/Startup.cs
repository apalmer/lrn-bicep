
using System;
using Microsoft.Azure.Functions.Extensions.DependencyInjection;
using Microsoft.Extensions.Configuration;
using Azure.Identity;

[assembly: FunctionsStartup(typeof(TestFunctionAlpha.Startup))]

namespace TestFunctionAlpha
{
    class Startup : FunctionsStartup
    {
        public override void ConfigureAppConfiguration(IFunctionsConfigurationBuilder builder)
        {
            string endpoint = Environment.GetEnvironmentVariable("AzureAppConfiguration:Endpoint");
            builder.ConfigurationBuilder.AddAzureAppConfiguration(options=> 
            {
                options
                    .Connect(new Uri(endpoint), new DefaultAzureCredential())
                    .ConfigureKeyVault(kv =>
                    {
                        kv.SetCredential(new DefaultAzureCredential());
                    });
            });
        }

        public override void Configure(IFunctionsHostBuilder builder)
        {
        }
    }
}
