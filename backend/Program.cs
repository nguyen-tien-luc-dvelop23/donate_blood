using System.Text;
using GiveNowBackend.Data;
using Microsoft.AspNetCore.Authentication.JwtBearer;
using Microsoft.EntityFrameworkCore;
using GiveNowBackend.Models;
using Microsoft.IdentityModel.Tokens;

var builder = WebApplication.CreateBuilder(args);

// Add services to the container.
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Enable CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll",
        builder =>
        {
            builder.AllowAnyOrigin()
                   .AllowAnyMethod()
                   .AllowAnyHeader();
        });
});

// Configure PostgreSQL Database
var databaseUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
var mysqlHost = Environment.GetEnvironmentVariable("MYSQLHOST");
var mysqlPort = Environment.GetEnvironmentVariable("MYSQLPORT");
var mysqlUser = Environment.GetEnvironmentVariable("MYSQLUSER");
var mysqlPass = Environment.GetEnvironmentVariable("MYSQLPASSWORD");
var mysqlDb = Environment.GetEnvironmentVariable("MYSQLDATABASE");

string connectionString;

if (!string.IsNullOrEmpty(mysqlHost))
{
    // PostgreSQL Connection String
    connectionString = $"Host={mysqlHost};Port={mysqlPort ?? "5432"};Database={mysqlDb ?? "railway"};Username={mysqlUser ?? "postgres"};Password={mysqlPass};SSL Mode=Require;Trust Server Certificate=true;";
    Console.WriteLine($"DB CONFIG: Attempting connection via MYSQLHOST [Host]: {mysqlHost}, [Port]: {mysqlPort ?? "5432"}");
}
else if (!string.IsNullOrEmpty(databaseUrl))
{
    // Railway's DATABASE_URL: postgresql://user:pass@host:port/db
    var uri = new Uri(databaseUrl);
    var userInfo = uri.UserInfo.Split(':');
    var port = uri.Port == -1 ? 5432 : uri.Port;
    var database = uri.AbsolutePath.TrimStart('/');
    connectionString = $"Host={uri.Host};Port={port};Database={database};Username={userInfo[0]};Password={userInfo[1]};SSL Mode=Require;Trust Server Certificate=true;";
    Console.WriteLine($"DB CONFIG: Attempting connection via DATABASE_URL [Host]: {uri.Host}, [Port]: {port}");
}
else
{
    connectionString = builder.Configuration.GetConnectionString("DefaultConnection")!;
}

builder.Services.AddDbContext<AppDbContext>(options =>
{
    options.UseNpgsql(connectionString, npgsqlOptions => 
    {
        npgsqlOptions.CommandTimeout(300);
        // Enable transient error resiliency
        npgsqlOptions.EnableRetryOnFailure(
            maxRetryCount: 10,
            maxRetryDelay: TimeSpan.FromSeconds(30),
            errorNumbersToAdd: null);
    });
});

// Configure JWT Authentication
builder.Services.AddAuthentication(options =>
{
    options.DefaultAuthenticateScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultChallengeScheme = JwtBearerDefaults.AuthenticationScheme;
    options.DefaultScheme = JwtBearerDefaults.AuthenticationScheme;
})
.AddJwtBearer(options =>
{
    options.SaveToken = true;
    options.RequireHttpsMetadata = false;
    options.TokenValidationParameters = new TokenValidationParameters()
    {
        ValidateIssuer = true,
        ValidateAudience = true,
        ValidAudience = builder.Configuration["JWT:ValidAudience"],
        ValidIssuer = builder.Configuration["JWT:ValidIssuer"],
        IssuerSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(builder.Configuration["JWT:Secret"]!))
    };
});

var app = builder.Build();

// Configure the HTTP request pipeline.
if (app.Environment.IsDevelopment() || app.Environment.IsStaging())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseCors("AllowAll");

// Remove UseHttpsRedirection in Docker environments behind reverse proxies unless configured
// app.UseHttpsRedirection();

app.UseAuthentication();
app.UseAuthorization();

app.MapControllers();

// Create tables and Seed Admin User in a BACKGROUND task to avoid Render port-scan timeout
_ = Task.Run(async () => {
    using (var scope = app.Services.CreateScope())
    {
        var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
        int maxRetries = 10;
        int retryDelayMs = 15000;

        for (int i = 1; i <= maxRetries; i++)
        {
            try
            {
                Console.WriteLine($"BACKGROUND: DB Initialization Attempt {i} of {maxRetries} (PostgreSQL)...");
                context.Database.SetCommandTimeout(300);

                // Create tables if not exists (PostgreSQL Syntax)
                context.Database.ExecuteSqlRaw(@"
                    CREATE TABLE IF NOT EXISTS ""Users"" (
                        ""Id"" uuid NOT NULL,
                        ""PhoneNumber"" varchar(20) NOT NULL,
                        ""PasswordHash"" text NOT NULL,
                        ""FullName"" varchar(100) NOT NULL DEFAULT '',
                        ""BloodType"" varchar(10) NOT NULL,
                        ""MedicalInfo"" text NOT NULL,
                        ""BloodVolume"" double precision NOT NULL DEFAULT 0.0,
                        ""AvatarUrl"" varchar(500) NOT NULL DEFAULT '',
                        ""CreatedAt"" timestamptz NOT NULL,
                        PRIMARY KEY (""Id"")
                    );
                ");

                context.Database.ExecuteSqlRaw(@"
                    CREATE UNIQUE INDEX IF NOT EXISTS ""IX_Users_PhoneNumber"" ON ""Users"" (""PhoneNumber"");
                ");

                context.Database.ExecuteSqlRaw(@"
                    CREATE TABLE IF NOT EXISTS ""SosRequests"" (
                        ""Id"" uuid NOT NULL,
                        ""UserId"" uuid NOT NULL,
                        ""BloodType"" varchar(10) NOT NULL,
                        ""Location"" varchar(255) NOT NULL,
                        ""Reason"" varchar(100) NOT NULL,
                        ""Description"" text NOT NULL,
                        ""Status"" varchar(20) NOT NULL,
                        ""CreatedAt"" timestamptz NOT NULL,
                        PRIMARY KEY (""Id""),
                        CONSTRAINT ""FK_SosRequests_Users_UserId"" FOREIGN KEY (""UserId"") REFERENCES ""Users"" (""Id"") ON DELETE CASCADE
                    );
                ");

                context.Database.ExecuteSqlRaw(@"
                    CREATE TABLE IF NOT EXISTS ""DonationRecords"" (
                        ""Id"" uuid NOT NULL,
                        ""UserId"" uuid NOT NULL,
                        ""HospitalName"" varchar(255) NOT NULL,
                        ""DonationDate"" timestamptz NOT NULL,
                        ""CreatedAt"" timestamptz NOT NULL,
                        PRIMARY KEY (""Id""),
                        CONSTRAINT ""FK_DonationRecords_Users"" FOREIGN KEY (""UserId"") REFERENCES ""Users"" (""Id"") ON DELETE CASCADE
                    );
                ");

                // Seed admin if not exists
                if (!context.Users.Any(u => u.PhoneNumber == "admin"))
                {
                    context.Users.Add(new User
                    {
                        PhoneNumber = "admin",
                        PasswordHash = BCrypt.Net.BCrypt.HashPassword("123456"),
                        BloodType = "Admin"
                    });
                    context.SaveChanges();
                }

                Console.WriteLine("BACKGROUND: DB Initialization Successful (PostgreSQL).");
                break;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"BACKGROUND: DB Initialization failed (Attempt {i}): {ex.Message}");
                if (i < maxRetries)
                {
                    await Task.Delay(retryDelayMs);
                }
            }
        }
    }
});

app.Run();
