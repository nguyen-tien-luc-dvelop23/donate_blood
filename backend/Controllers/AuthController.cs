using System.IdentityModel.Tokens.Jwt;
using System.Security.Claims;
using System.Text;
using GiveNowBackend.Data;
using GiveNowBackend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using Microsoft.IdentityModel.Tokens;

namespace GiveNowBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
public class AuthController : ControllerBase
{
    private readonly AppDbContext _context;
    private readonly IConfiguration _configuration;

    public AuthController(AppDbContext context, IConfiguration configuration)
    {
        _context = context;
        _configuration = configuration;
    }

    [HttpPost("register")]
    public async Task<IActionResult> Register([FromBody] RegisterRequest request)
    {
        if (await _context.Users.AnyAsync(u => u.PhoneNumber == request.PhoneNumber))
            return BadRequest("Phone number already exists");

        var user = new User
        {
            PhoneNumber = request.PhoneNumber,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName ?? string.Empty,
            BloodType = request.BloodType ?? string.Empty
        };

        _context.Users.Add(user);
        await _context.SaveChangesAsync();

        return Ok(new { Message = "User registered successfully" });
    }

    [HttpPost("login")]
    public async Task<IActionResult> Login([FromBody] LoginRequest request)
    {
        var user = await _context.Users.FirstOrDefaultAsync(u => u.PhoneNumber == request.PhoneNumber);
        if (user == null || !BCrypt.Net.BCrypt.Verify(request.Password, user.PasswordHash))
            return Unauthorized("Invalid phone number or password");

        var token = GenerateJwtToken(user);
        var donationCount = await _context.DonationRecords.CountAsync(d => d.UserId == user.Id);

        return Ok(new { 
            Token = token, 
            User = new { 
                user.Id, 
                user.PhoneNumber, 
                user.FullName, 
                user.BloodType, 
                user.BloodVolume, 
                user.AvatarUrl,
                DonationCount = donationCount 
            } 
        });
    }

    public class UpdateProfileRequest
    {
        public string? FullName { get; set; }
        public string? BloodType { get; set; }
        public string? AvatarUrl { get; set; }
    }

    [Authorize]
    [HttpPut("profile")]
    public async Task<IActionResult> UpdateProfile([FromBody] UpdateProfileRequest request)
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
            return Unauthorized("User ID not found in token");

        var user = await _context.Users.FindAsync(userId);
        if (user == null) return NotFound("User not found");

        if (!string.IsNullOrEmpty(request.FullName)) user.FullName = request.FullName;
        if (!string.IsNullOrEmpty(request.BloodType)) user.BloodType = request.BloodType;
        if (request.AvatarUrl != null) user.AvatarUrl = request.AvatarUrl; // Allow empty string to clear avatar

        await _context.SaveChangesAsync();

        return Ok(new { Message = "Profile updated successfully" });
    }

    [HttpPost("send-otp")]
    public IActionResult SendOtp([FromBody] OtpRequest request)
    {
        // Mock OTP sending
        return Ok(new { Message = $"OTP sent to {request.PhoneNumber}", MockOtp = "12345" });
    }

    private string GenerateJwtToken(User user)
    {
        var authClaims = new List<Claim>
        {
            new Claim(ClaimTypes.NameIdentifier, user.Id.ToString()),
            new Claim(ClaimTypes.MobilePhone, user.PhoneNumber),
            new Claim(JwtRegisteredClaimNames.Jti, Guid.NewGuid().ToString())
        };

        var authSigningKey = new SymmetricSecurityKey(Encoding.UTF8.GetBytes(_configuration["JWT:Secret"] ?? "SuperSecretKeyForJWTAuthReplaceThisInProd"));

        var token = new JwtSecurityToken(
            issuer: _configuration["JWT:ValidIssuer"],
            audience: _configuration["JWT:ValidAudience"],
            expires: DateTime.Now.AddHours(3),
            claims: authClaims,
            signingCredentials: new SigningCredentials(authSigningKey, SecurityAlgorithms.HmacSha256)
        );

        return new JwtSecurityTokenHandler().WriteToken(token);
    }
}

public class RegisterRequest
{
    public string PhoneNumber { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? FullName { get; set; }
    public string? BloodType { get; set; }
}

public class LoginRequest
{
    public string PhoneNumber { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
}

public class OtpRequest
{
    public string PhoneNumber { get; set; } = string.Empty;
}
