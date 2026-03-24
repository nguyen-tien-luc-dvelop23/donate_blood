using System.ComponentModel.DataAnnotations;

namespace GiveNowBackend.Models;

public class User
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    [MaxLength(20)]
    public string PhoneNumber { get; set; } = string.Empty;

    [Required]
    public string PasswordHash { get; set; } = string.Empty;

    [MaxLength(100)]
    public string FullName { get; set; } = string.Empty;

    [MaxLength(10)]
    public string BloodType { get; set; } = string.Empty;

    public string MedicalInfo { get; set; } = string.Empty;

    [MaxLength(500)]
    public string AvatarUrl { get; set; } = string.Empty;

    public double BloodVolume { get; set; } = 0.0;

    public double Latitude { get; set; } = 0.0;
    public double Longitude { get; set; } = 0.0;

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
