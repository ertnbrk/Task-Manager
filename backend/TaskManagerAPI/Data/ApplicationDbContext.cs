using Microsoft.EntityFrameworkCore;
using TaskManagerAPI.Models;
namespace TaskManagerAPI.Data
{
    public class ApplicationDbContext : DbContext
    {
        public ApplicationDbContext(DbContextOptions<ApplicationDbContext> options) : base(options) { }

        public DbSet<AppTask> Tasks { get; set; }
        public DbSet<ApplicationUser> ApplicationUsers { get; set; }

    }
}
