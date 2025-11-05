namespace iredo.Api.Services;

public static class DatabaseConfig
{
    public static void Configure(IServiceCollection services, string connectionString)
    {
        // Database: MySQL
        /*
        services.AddDbContext<IredoDbContext>(options =>
            options.UseMySql(connectionString,
                new MySqlServerVersion(new Version(8, 0, 29))));
        */
    }
    
}