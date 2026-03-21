using GiveNowBackend.Data;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using Microsoft.EntityFrameworkCore;

namespace GiveNowBackend.Controllers;

[Route("api/[controller]")]
[ApiController]
[Authorize] // Requires professional JWT setup, for now we will check in method or just use it
public class UsersController : ControllerBase
{
    private readonly AppDbContext _context;

    public UsersController(AppDbContext context)
    {
        _context = context;
    }

    [HttpGet]
    public async Task<IActionResult> GetAllUsers()
    {
        // Simple admin check based on phone for now
        var adminPhone = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.MobilePhone)?.Value;
        if (adminPhone != "admin")
            return Forbid("Only admin can access this");

        var users = await _context.Users
            .Select(u => new { u.Id, u.PhoneNumber, u.BloodType, u.CreatedAt })
            .ToListAsync();
        return Ok(users);
    }

    [HttpDelete("{id}")]
    public async Task<IActionResult> DeleteUser(Guid id)
    {
        var adminPhone = User.Claims.FirstOrDefault(c => c.Type == System.Security.Claims.ClaimTypes.MobilePhone)?.Value;
        if (adminPhone != "admin")
            return Forbid();

        var user = await _context.Users.FindAsync(id);
        if (user == null)
            return NotFound();

        if (user.PhoneNumber == "admin")
            return BadRequest("Cannot delete admin account");

        _context.Users.Remove(user);
        await _context.SaveChangesAsync();

        return Ok(new { Message = "User deleted successfully" });
    }
}
