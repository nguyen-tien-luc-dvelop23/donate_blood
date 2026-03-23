using GiveNowBackend.Models;
using Microsoft.EntityFrameworkCore;

namespace GiveNowBackend.Data;

public class AppDbContext : DbContext
{
    public AppDbContext(DbContextOptions<AppDbContext> options) : base(options)
    {
    }

    public DbSet<User> Users { get; set; }
    public DbSet<SosRequest> SosRequests { get; set; }
    public DbSet<DonationRecord> DonationRecords { get; set; }
    public DbSet<ChatMessage> ChatMessages { get; set; }
    public DbSet<Notification> Notifications { get; set; }
    public DbSet<UserAvatar> UserAvatars { get; set; }

    protected override void OnModelCreating(ModelBuilder modelBuilder)
    {
        base.OnModelCreating(modelBuilder);
        
        modelBuilder.Entity<User>()
            .HasIndex(u => u.PhoneNumber)
            .IsUnique();
    }
}
