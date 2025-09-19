using System.Device.I2c;
using System.Net;
using System.Text;

class Program
{
    const int I2cBusId = 1;
    const int Address = 0x40;

    static void Main()
    {
        var portEnv = Environment.GetEnvironmentVariable("PORT");
        int port = int.TryParse(portEnv, out var p) ? p : 273;

        // Create I²C device
        var settings = new I2cConnectionSettings(I2cBusId, Address);
        using var device = I2cDevice.Create(settings);

        // Start HTTP server
        var listener = new HttpListener();
        listener.Prefixes.Add($"http://*:{port}/"); // listen on all interfaces
        listener.Start();
        Console.WriteLine($"Listening on http://0.0.0.0:{port}/ ...");

        while (true)
        {
            var ctx = listener.GetContext();
            var req = ctx.Request;
            var res = ctx.Response;

            Console.WriteLine($"{DateTime.UtcNow:O} {req.RemoteEndPoint} {req.HttpMethod} {req.Url}");

            var path = req.Url?.AbsolutePath ?? string.Empty;

            if (path == "/")
            {
                double temp = ReadTemperature(device);
                double hum = ReadHumidity(device);

                string json = $"{{\"sensor\":\"HTU21D/SHT21\",\"temperature_c\":{temp:F2},\"humidity_percent\":{hum:F2},\"timestamp_utc\":\"{DateTime.UtcNow:O}\"}}";
                byte[] buffer = Encoding.UTF8.GetBytes(json);
                res.ContentType = "application/json";
                res.OutputStream.Write(buffer, 0, buffer.Length);
            }
            else if (path == "/health")
            {
                string json = "{\"status\":\"ok\"}";
                byte[] buffer = Encoding.UTF8.GetBytes(json);
                res.ContentType = "application/json";
                res.OutputStream.Write(buffer, 0, buffer.Length);
            }
            else
            {
                res.StatusCode = 404;
            }

            res.OutputStream.Close();
        }
    }

    static double ReadTemperature(I2cDevice device)
    {
        device.WriteByte(0xF3);
        Thread.Sleep(50);
        Span<byte> data = stackalloc byte[2];
        device.Read(data);
        int raw = (data[0] << 8) | data[1];
        return -46.85 + (175.72 * raw / 65536.0);
    }

    static double ReadHumidity(I2cDevice device)
    {
        device.WriteByte(0xF5);
        Thread.Sleep(50);
        Span<byte> data = stackalloc byte[2];
        device.Read(data);
        int raw = (data[0] << 8) | data[1];
        return -6.0 + (125.0 * raw / 65536.0);
    }
}
