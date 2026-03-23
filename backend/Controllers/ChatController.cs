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

    // GET list of all users to start a DM with
    [HttpGet("users")]
    public async Task<IActionResult> GetUsers()
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        Guid.TryParse(userIdStr, out var myId);

        var users = await _context.Users
            .Where(u => u.Id != myId && u.PhoneNumber != "admin")
            .Select(u => new {
                id = u.Id,
                fullName = u.FullName,
                phoneNumber = u.PhoneNumber,
                bloodType = u.BloodType,
                avatarUrl = u.AvatarUrl
            })
            .ToListAsync();
        return Ok(users);
    }

    // GET conversations list - last message with each user
    [HttpGet("conversations")]
    public async Task<IActionResult> GetConversations()
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdStr, out var myId)) return Unauthorized();

        try {
            var msgs = await _context.ChatMessages
                .Include(m => m.Sender)
                .Include(m => m.Recipient)
                .Where(m => m.RecipientId != null &&
                            (m.SenderId == myId || m.RecipientId == myId))
                .OrderByDescending(m => m.CreatedAt)
                .ToListAsync();

            var conversations = msgs
                .GroupBy(m => m.SenderId == myId ? m.RecipientId!.Value : m.SenderId)
                .Select(g => {
                    var last = g.First();
                    var otherId = last.SenderId == myId ? last.RecipientId!.Value : last.SenderId;
                    var other = last.SenderId == myId ? last.Recipient : last.Sender;
                    return new {
                        userId = otherId,
                        userName = other?.FullName ?? "",
                        userPhone = other?.PhoneNumber ?? "",
                        userAvatar = other?.AvatarUrl ?? "",
                        userBloodType = other?.BloodType ?? "",
                        lastMessage = last.Content,
                        lastTime = last.CreatedAt,
                        unread = g.Count(m => m.SenderId == otherId)
                    };
                })
                .ToList();

            return Ok(conversations);
        } catch (Exception ex) {
            Console.WriteLine($"GetConversations error: {ex.Message}");
            return Ok(new List<object>()); // Return empty on schema mismatch
        }
    }

    // GET DM messages with a specific user
    [HttpGet("dm/{recipientId}")]
    public async Task<IActionResult> GetDm(Guid recipientId, [FromQuery] int skip = 0)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdStr, out var myId)) return Unauthorized();

        try {
            var messages = await _context.ChatMessages
                .Include(m => m.Sender)
                .Where(m => m.RecipientId != null &&
                            ((m.SenderId == myId && m.RecipientId == recipientId) ||
                             (m.SenderId == recipientId && m.RecipientId == myId)))
                .OrderBy(m => m.CreatedAt)
                .Skip(skip).Take(100)
                .Select(m => new {
                    m.Id,
                    m.Content,
                    m.CreatedAt,
                    senderId = m.SenderId,
                    senderName = m.Sender!.FullName,
                    senderPhone = m.Sender!.PhoneNumber,
                    senderAvatar = m.Sender!.AvatarUrl
                })
                .ToListAsync();

            return Ok(messages);
        } catch (Exception ex) {
            Console.WriteLine($"GetDm error: {ex.Message}");
            return Ok(new List<object>()); // Return empty on schema mismatch
        }
    }

    // POST send a DM to a specific user
    [HttpPost("dm")]
    public async Task<IActionResult> SendDm([FromBody] SendDmRequest request)
    {
        var userIdStr = User.FindFirst(ClaimTypes.NameIdentifier)?.Value;
        if (!Guid.TryParse(userIdStr, out var myId)) return Unauthorized();

        if (string.IsNullOrWhiteSpace(request.Content)) return BadRequest("Nội dung không được trống");

        var recipient = await _context.Users.FindAsync(request.RecipientId);
        if (recipient == null) return NotFound("Người nhận không tồn tại");

        var msg = new ChatMessage
        {
            SenderId = myId,
            RecipientId = request.RecipientId,
            Content = request.Content.Trim()
        };

        try {
            _context.ChatMessages.Add(msg);

            // Notify recipient
            try {
                _context.Notifications.Add(new Notification {
                    UserId = request.RecipientId,
                    Title = "💬 Tin nhắn mới",
                    Body = $"Bạn có tin nhắn mới từ {(await _context.Users.FindAsync(myId))?.FullName ?? "someone"}",
                    Type = "chat"
                });
            } catch { /* notifications table may not exist yet */ }

            await _context.SaveChangesAsync();
        } catch (Exception ex) {
            Console.WriteLine($"SendDm error: {ex.Message}");
            return BadRequest("Máy chủ đang cập nhật dữ liệu chat. Hãy thử lại sau vài phút!");
        }

        var sender = await _context.Users.FindAsync(myId);
        return Ok(new {
            msg.Id, msg.Content, msg.CreatedAt,
            senderId = myId,
            senderName = sender?.FullName ?? "",
            senderPhone = sender?.PhoneNumber ?? "",
            senderAvatar = sender?.AvatarUrl ?? ""
        });
    }
}

public class SendMessageRequest { public string Content { get; set; } = string.Empty; }
public class SendDmRequest {
    public Guid RecipientId { get; set; }
    public string Content { get; set; } = string.Empty;
}
