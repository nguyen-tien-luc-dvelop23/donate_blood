using System.Security.Claims;
using GiveNowBackend.Data;
using GiveNowBackend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiveNowBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class SosController : ControllerBase
{
    private readonly AppDbContext _context;

    public SosController(AppDbContext context)
    {
        _context = context;
    }

    [HttpPost]
    public async Task<IActionResult> CreateSos([FromBody] CreateSosDto request)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            return Unauthorized("User not found in token.");
        }

        var sosRequest = new SosRequest
        {
            UserId = userId,
            BloodType = request.BloodType,
            Location = request.Location,
            Reason = request.Reason,
            Description = request.Description,
            Status = "Pending",
            CreatedAt = DateTime.UtcNow
        };

        _context.SosRequests.Add(sosRequest);
        await _context.SaveChangesAsync();

        return Ok(new { Message = "SOS request created successfully", Id = sosRequest.Id });
    }

    [HttpGet("history")]
    public async Task<IActionResult> GetMyHistory()
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            return Unauthorized("User not found in token.");
        }

        var requests = await _context.SosRequests
            .Where(s => s.UserId == userId)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new {
                s.Id,
                s.BloodType,
                s.Location,
                s.Reason,
                s.Description,
                s.Status,
                s.CreatedAt
            })
            .ToListAsync();

        return Ok(requests);
    }
}

public class CreateSosDto
{
    public string BloodType { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
