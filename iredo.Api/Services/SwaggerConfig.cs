using Microsoft.OpenApi.Models;

namespace iredo.Api.Services;

public static class SwaggerConfig
{
    public static void Configure(IServiceCollection services)
    {
        services.AddSwaggerGen(c =>
        {
            c.SwaggerDoc("v1", new OpenApiInfo { Title = "iredo_v1", Version = "v1" });
        });
    }
}