using System.ComponentModel.DataAnnotations;

namespace TaskManagerAPI.Models
{
    public class AppTask
    {
        [Key]
        public Guid Id { get; set; }  

        [Required]
        public string? Title { get; set; }

        public string? Description { get; set; }

        public bool IsCompleted { get; set; }
        private DateTime? _dueDate;
        public DateTime? DueDate
        {
            get => _dueDate;
            set => _dueDate = value?.ToUniversalTime(); // ✅ Convert to UTC before storing
        }

        public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
        public string UserId { get; set; }  // Add this line

    }
}
