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

// Configure MySQL Database
var databaseUrl = Environment.GetEnvironmentVariable("DATABASE_URL");
string connectionString;

if (!string.IsNullOrEmpty(databaseUrl))
{
    // Convert mysql:// URI to ADO.NET connection string
    var uri = new Uri(databaseUrl);
    var userInfo = uri.UserInfo.Split(':');
    connectionString = $"Server={uri.Host};Port={uri.Port};Database={uri.AbsolutePath.TrimStart('/')};Uid={userInfo[0]};Pwd={userInfo[1]};";
}
else
{
    connectionString = builder.Configuration.GetConnectionString("DefaultConnection")!;
}

builder.Services.AddDbContext<AppDbContext>(options =>
    options.UseMySql(connectionString, new MySqlServerVersion(new Version(8, 0, 35))));

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

// Create tables and Seed Admin User
using (var scope = app.Services.CreateScope())
{
    var context = scope.ServiceProvider.GetRequiredService<AppDbContext>();
    
    // Drop old table if schema is wrong, then recreate
    context.Database.ExecuteSqlRaw("DROP TABLE IF EXISTS `Users`;");
    
    // Create Users table explicitly using raw SQL
    context.Database.ExecuteSqlRaw(@"
        CREATE TABLE IF NOT EXISTS `Users` (
            `Id` char(36) NOT NULL,
            `PhoneNumber` varchar(20) NOT NULL,
            `PasswordHash` longtext NOT NULL,
            `FullName` varchar(100) NOT NULL DEFAULT '',
            `BloodType` varchar(10) NOT NULL,
            `MedicalInfo` longtext NOT NULL,
            `BloodVolume` double NOT NULL DEFAULT 0.0,
            `DonationCount` int NOT NULL DEFAULT 0,
            `CreatedAt` datetime(6) NOT NULL,
            PRIMARY KEY (`Id`),
            UNIQUE KEY `IX_Users_PhoneNumber` (`PhoneNumber`)
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
    ");

    // Create SosRequests table explicitly using raw SQL
    context.Database.ExecuteSqlRaw(@"
        CREATE TABLE IF NOT EXISTS `SosRequests` (
            `Id` char(36) NOT NULL,
            `UserId` char(36) NOT NULL,
            `BloodType` varchar(10) NOT NULL,
            `Location` varchar(255) NOT NULL,
            `Reason` varchar(100) NOT NULL,
            `Description` longtext NOT NULL,
            `Status` varchar(20) NOT NULL,
            `CreatedAt` datetime(6) NOT NULL,
            PRIMARY KEY (`Id`),
            CONSTRAINT `FK_SosRequests_Users_UserId` FOREIGN KEY (`UserId`) REFERENCES `Users` (`Id`) ON DELETE CASCADE
        ) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;
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
}

app.Run();
