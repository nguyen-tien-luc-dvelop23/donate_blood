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
            .Where(u => u.PhoneNumber != "admin" && u.BloodVolume > 0)
            .OrderByDescending(u => u.BloodVolume)
            .Take(limit)
            .Select(u => new {
                u.Id,
                u.FullName,
                u.PhoneNumber,
                u.BloodType,
                u.BloodVolume,
                u.AvatarUrl,
                DonationCount = _context.DonationRecords.Count(d => d.UserId == u.Id)
            })
            .ToListAsync();

        var totalVolume = await _context.Users.SumAsync(u => u.BloodVolume);
        var totalMembers = await _context.Users.CountAsync(u => u.PhoneNumber != "admin");

        return Ok(new {
            Users = users,
            TotalVolumeMl = totalVolume,
            TotalMembers = totalMembers
        });
    }
}
