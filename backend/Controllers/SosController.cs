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

        // Notify all other users about new SOS
        var allUserIds = await _context.Users
            .Where(u => u.Id != userId && u.PhoneNumber != "admin")
            .Select(u => u.Id)
            .ToListAsync();

        foreach (var targetId in allUserIds)
        {
            _context.Notifications.Add(new Notification
            {
                UserId = targetId,
                Title = $"🆘 SOS khẩn cấp - Nhóm {request.BloodType}",
                Body = $"Cần máu gấp tại {request.Location}. Lý do: {request.Reason}",
                Type = "sos"
            });
        }

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

    [HttpGet("active")]
    public async Task<IActionResult> GetActiveSos()
    {
        var requests = await _context.SosRequests
            .Where(s => s.Status == "Pending")
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new {
                s.Id,
                s.UserId,
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

    [HttpPost("{id}/confirm")]
    public async Task<IActionResult> ConfirmSos(Guid id)
    {
        var userIdString = User.FindFirstValue(ClaimTypes.NameIdentifier);
        if (string.IsNullOrEmpty(userIdString) || !Guid.TryParse(userIdString, out var userId))
        {
            return Unauthorized("User not found in token.");
        }

        var sos = await _context.SosRequests.FindAsync(id);
        if (sos == null) return NotFound("SOS not found");
        if (sos.Status != "Pending") return BadRequest("SOS is no longer pending");
        if (sos.UserId == userId) return BadRequest("Cannot confirm your own SOS");

        sos.Status = "Accepted";
        await _context.SaveChangesAsync();
        
        return Ok(new { Message = "Confirmed successfully" });
    }
}

public class CreateSosDto
{
    public string BloodType { get; set; } = string.Empty;
    public string Location { get; set; } = string.Empty;
    public string Reason { get; set; } = string.Empty;
    public string Description { get; set; } = string.Empty;
}
