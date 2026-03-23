using System.ComponentModel.DataAnnotations;
using System.ComponentModel.DataAnnotations.Schema;

namespace GiveNowBackend.Models
{
    public class UserAvatar
    {
        [Key]
        [StringLength(36)]
        public string UserId { get; set; } = string.Empty;

        [Required]
        public byte[] AvatarData { get; set; } = Array.Empty<byte>();

        [Required]
        [StringLength(50)]
        public string ContentType { get; set; } = "image/jpeg";
        
        [ForeignKey("UserId")]
        public User? User { get; set; }
    }
}
