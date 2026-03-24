using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GiveNowBackend.Models;

public class SosRequest
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid UserId { get; set; }

    [ForeignKey("UserId")]
    public User? User { get; set; }

    [Required]
    [MaxLength(10)]
    public string BloodType { get; set; } = string.Empty;

    [Required]
    [MaxLength(255)]
    public string Location { get; set; } = string.Empty;

    [Required]
    [MaxLength(100)]
    public string Reason { get; set; } = string.Empty;

    public string Description { get; set; } = string.Empty;

    public double Latitude { get; set; } = 0.0;
    public double Longitude { get; set; } = 0.0;

    [Required]
    [MaxLength(20)]
    public string Status { get; set; } = "Pending"; // Pending, Fulfilled, Cancelled

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
