using GiveNowBackend.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiveNowBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class LeaderboardController : ControllerBase
{
    private readonly AppDbContext _context;

    public LeaderboardController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetLeaderboard([FromQuery] int limit = 50)
    {
        var users = await _context.Users
            .Where(u => u.PhoneNumber != "admin")
            .OrderByDescending(u => u.BloodVolume)
            .Take(limit)
            .Select(u => new {
                id = u.Id,
                fullName = u.FullName,
                phoneNumber = u.PhoneNumber,
                bloodType = u.BloodType,
                bloodVolume = u.BloodVolume,
                avatarUrl = u.AvatarUrl,
                donationCount = _context.DonationRecords.Count(d => d.UserId == u.Id)
            })
            .ToListAsync();

        var totalVolume = await _context.Users.Where(u => u.PhoneNumber != "admin").SumAsync(u => u.BloodVolume);
        var totalMembers = await _context.Users.CountAsync(u => u.PhoneNumber != "admin");

        return Ok(new {
            users,
            totalVolumeMl = totalVolume,
            totalMembers
        });
    }
}
