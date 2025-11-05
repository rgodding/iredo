using Microsoft.AspNetCore.Mvc;

namespace iredo.Api.Controllers;

[ApiController]
[Route("api/[controller]")]
public class Rooms : ControllerBase
{
    [HttpGet]
    public async Task<ActionResult> GetRooms()
    {
        const string rooms = "okay room, hello world";
        return Ok(rooms);
    }
    
}