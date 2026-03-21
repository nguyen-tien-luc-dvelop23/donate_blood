using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using GiveNowBackend.Data;
using GiveNowBackend.Models;
using System.Security.Claims;

namespace GiveNowBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class DonationController : ControllerBase
{
    private readonly AppDbContext _context;

    public DonationController(AppDbContext context)
    {
        _context = context;
    }

    [Authorize]
    [HttpGet("history")]
    public async Task<IActionResult> GetMyHistory()
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
            return Unauthorized("User ID not found in token");

        var history = await _context.DonationRecords
            .Where(d => d.UserId == userId)
            .OrderByDescending(d => d.DonationDate)
            .Select(d => new { d.Id, d.HospitalName, d.DonationDate, d.CreatedAt })
            .ToListAsync();

        return Ok(history);
    }

    [Authorize]
    [HttpPost("add")]
    public async Task<IActionResult> AddDonation([FromBody] AddDonationRequest request)
    {
        var userIdString = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
            return Unauthorized("User ID not found in token");

        var record = new DonationRecord
        {
            UserId = userId,
            HospitalName = request.HospitalName,
            DonationDate = request.DonationDate ?? DateTime.UtcNow
        };

        _context.DonationRecords.Add(record);
        await _context.SaveChangesAsync();

        return Ok(new { Message = "Donation record added successfully", Record = record });
    }
}

public class AddDonationRequest
{
    public string HospitalName { get; set; } = string.Empty;
    public DateTime? DonationDate { get; set; }
}
