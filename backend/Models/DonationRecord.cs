using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GiveNowBackend.Models;

public class DonationRecord
{
    [Key]
    public Guid Id { get; set; } = Guid.NewGuid();

    [Required]
    public Guid UserId { get; set; }

    [ForeignKey("UserId")]
    public User? User { get; set; }

    [Required]
    [MaxLength(255)]
    public string HospitalName { get; set; } = string.Empty;

    public DateTime DonationDate { get; set; }

    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
}
