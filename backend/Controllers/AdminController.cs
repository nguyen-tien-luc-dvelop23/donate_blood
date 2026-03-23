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
public class AdminController : ControllerBase
{
    private readonly AppDbContext _context;

    public AdminController(AppDbContext context)
    {
        _context = context;
    }

    private bool IsAdmin()
    {
        var phone = User.Claims.FirstOrDefault(c => c.Type == ClaimTypes.MobilePhone)?.Value;
        return phone == "admin";
    }

    // === USERS ===

    [HttpGet("users")]
    public async Task<IActionResult> GetAllUsers()
    {
        if (!IsAdmin()) return Forbid();
        var users = await _context.Users
            .Select(u => new {
                u.Id, u.PhoneNumber, u.FullName, u.BloodType, u.BloodVolume, u.AvatarUrl, u.CreatedAt
            })
            .OrderBy(u => u.PhoneNumber)
            .ToListAsync();
        return Ok(users);
    }

    [HttpPost("users")]
    public async Task<IActionResult> CreateUser([FromBody] CreateUserRequest request)
    {
        if (!IsAdmin()) return Forbid();
        if (await _context.Users.AnyAsync(u => u.PhoneNumber == request.PhoneNumber))
            return BadRequest("Số điện thoại đã tồn tại");

        var user = new User
        {
            PhoneNumber = request.PhoneNumber,
            PasswordHash = BCrypt.Net.BCrypt.HashPassword(request.Password),
            FullName = request.FullName ?? string.Empty,
            BloodType = request.BloodType ?? string.Empty
        };
        _context.Users.Add(user);
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Tạo người dùng thành công", User = new { user.Id, user.PhoneNumber, user.FullName, user.BloodType } });
    }

    [HttpDelete("users/{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        if (!IsAdmin()) return Forbid();
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();
        if (user.PhoneNumber == "admin") return BadRequest("Không thể xóa tài khoản admin");
        _context.Users.Remove(user);
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Xóa người dùng thành công" });
    }

    [HttpPut("users/{id}/blood-volume")]
    public async Task<IActionResult> UpdateBloodVolume(Guid id, [FromBody] UpdateBloodVolumeRequest request)
    {
        if (!IsAdmin()) return Forbid();
        var user = await _context.Users.FindAsync(id);
        if (user == null) return NotFound();
        user.BloodVolume = request.BloodVolume;
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Cập nhật thể tích máu thành công", BloodVolume = user.BloodVolume });
    }

    // === DONATIONS ===

    [HttpGet("donations")]
    public async Task<IActionResult> GetAllDonations()
    {
        if (!IsAdmin()) return Forbid();
        var donations = await _context.DonationRecords
            .Include(d => d.User)
            .OrderByDescending(d => d.DonationDate)
            .Select(d => new {
                d.Id,
                d.HospitalName,
                d.DonationDate,
                d.CreatedAt,
                UserId = d.UserId,
                UserPhone = d.User!.PhoneNumber,
                UserName = d.User!.FullName,
                UserBloodType = d.User!.BloodType
            })
            .ToListAsync();
        return Ok(donations);
    }

    [HttpPost("donations")]
    public async Task<IActionResult> AddDonationForUser([FromBody] AdminAddDonationRequest request)
    {
        if (!IsAdmin()) return Forbid();
        var user = await _context.Users.FindAsync(request.UserId);
        if (user == null) return NotFound("Người dùng không tồn tại");

        var record = new DonationRecord
        {
            UserId = request.UserId,
            HospitalName = request.HospitalName,
            DonationDate = request.DonationDate ?? DateTime.UtcNow
        };

        // Update blood volume (350ml per donation by default)
        user.BloodVolume += request.BloodVolumeMl > 0 ? request.BloodVolumeMl : 350;

        _context.DonationRecords.Add(record);
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Xác nhận hiến máu thành công", Record = record });
    }

    [HttpDelete("donations/{id}")]
    public async Task<IActionResult> DeleteDonation(Guid id)
    {
        if (!IsAdmin()) return Forbid();
        var record = await _context.DonationRecords.Include(d => d.User).FirstOrDefaultAsync(d => d.Id == id);
        if (record == null) return NotFound();

        // Subtract blood volume
        if (record.User != null) record.User.BloodVolume = Math.Max(0, record.User.BloodVolume - 350);

        _context.DonationRecords.Remove(record);
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Xóa bản ghi hiến máu thành công" });
    }

    // === SOS REQUESTS ===

    [HttpGet("sos")]
    public async Task<IActionResult> GetAllSos()
    {
        if (!IsAdmin()) return Forbid();
        var requests = await _context.SosRequests
            .Include(s => s.User)
            .OrderByDescending(s => s.CreatedAt)
            .Select(s => new {
                s.Id, s.BloodType, s.Location, s.Reason, s.Description, s.Status, s.CreatedAt,
                UserId = s.UserId,
                UserPhone = s.User!.PhoneNumber,
                UserName = s.User!.FullName
            })
            .ToListAsync();
        return Ok(requests);
    }

    [HttpPut("sos/{id}/status")]
    public async Task<IActionResult> UpdateSosStatus(Guid id, [FromBody] UpdateSosStatusRequest request)
    {
        if (!IsAdmin()) return Forbid();
        var sos = await _context.SosRequests.FindAsync(id);
        if (sos == null) return NotFound();
        sos.Status = request.Status;
        await _context.SaveChangesAsync();
        return Ok(new { Message = "Cập nhật trạng thái SOS thành công", Status = sos.Status });
    }
}

public class CreateUserRequest
{
    public string PhoneNumber { get; set; } = string.Empty;
    public string Password { get; set; } = string.Empty;
    public string? FullName { get; set; }
    public string? BloodType { get; set; }
}

public class UpdateBloodVolumeRequest
{
    public double BloodVolume { get; set; }
}

public class AdminAddDonationRequest
{
    public Guid UserId { get; set; }
    public string HospitalName { get; set; } = string.Empty;
    public DateTime? DonationDate { get; set; }
    public double BloodVolumeMl { get; set; } = 350;
}

public class UpdateSosStatusRequest
{
    public string Status { get; set; } = "Pending";
}
