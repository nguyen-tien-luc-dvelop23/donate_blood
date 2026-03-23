using GiveNowBackend.Data;
using GiveNowBackend.Models;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;
using System.Security.Claims;

namespace GiveNowBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize]
public class ChatController : ControllerBase
{
    private readonly AppDbContext _context;

    public ChatController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetMessages([FromQuery] int limit = 50, [FromQuery] string? after = null)
    {
        var query = _context.ChatMessages
            .Include(m => m.Sender)
            .AsQueryable();

        if (!string.IsNullOrEmpty(after) && DateTime.TryParse(after, out var afterDate))
            query = query.Where(m => m.CreatedAt > afterDate);

        var messages = await query
            .OrderBy(m => m.CreatedAt)
            .TakeLast(limit)
            .Select(m => new {
                m.Id,
                m.Content,
                m.CreatedAt,
                SenderId = m.SenderId,
                SenderName = m.Sender!.FullName,
                SenderPhone = m.Sender!.PhoneNumber,
                SenderBloodType = m.Sender!.BloodType,
                SenderAvatar = m.Sender!.AvatarUrl
            })
            .ToListAsync();

        return Ok(messages);
    }

    [HttpPost]
    public async Task<IActionResult> SendMessage([FromBody] SendMessageRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (string.IsNullOrEmpty(userIdStr) || !Guid.TryParse(userIdStr, out var userId))
            return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.Content))
            return BadRequest("Nội dung không được trống");

        var msg = new ChatMessage
        {
            SenderId = userId,
            Content = request.Content.Trim()
        };

        _context.ChatMessages.Add(msg);
        await _context.SaveChangesAsync();

        var sender = await _context.Users.FindAsync(userId);
        return Ok(new {
            msg.Id,
            msg.Content,
            msg.CreatedAt,
            SenderId = userId,
            SenderName = sender?.FullName ?? "",
            SenderPhone = sender?.PhoneNumber ?? "",
            SenderBloodType = sender?.BloodType ?? "",
            SenderAvatar = sender?.AvatarUrl ?? ""
        });
    }
}

public class SendMessageRequest
{
    public string Content { get; set; } = string.Empty;
}
