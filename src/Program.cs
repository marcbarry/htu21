using System.Device.I2c;
using System.Net;
using System.Text;

class Program
{
    const int I2cBusId = 1;
    const int Address = 0x40;

    static void Main()
    {
        var portEnv = Environment.GetEnvironmentVariable("HTU21_PORT");
        int port = int.TryParse(portEnv, out var p) ? p : 273;

        var settings = new I2cConnectionSettings(I2cBusId, Address);
        
        using var device = I2cDevice.Create(settings);

        var sensor = new Sht21(device);

        using var listener = new HttpListener();
        listener.Prefixes.Add($"http://*:{port}/");
        listener.Start();

        Console.WriteLine($"Listening on http://0.0.0.0:{port}/");

        for (;;)
        {
            var ctx = listener.GetContext();
            var req = ctx.Request;
            var res = ctx.Response;

            try
            {
                switch (req.Url?.AbsolutePath)
                {
                    case "/":
                    {
                        double tempC = sensor.ReadTemperatureC();
                        double rh = sensor.ReadHumidityPercent();

                        var payload = $"{{\"sensor\":\"HTU21/SHT21\",\"temperature_c\":{tempC:F2},\"humidity_percent\":{rh:F2},\"timestamp_utc\":\"{DateTime.UtcNow:O}\"}}";

                        WriteJson(res, 200, payload);

                        break;
                    }
                    case "/health":
                        WriteJson(res, 200, "{\"status\":\"ok\"}");
                        break;

                    default:
                        res.StatusCode = 404;
                        res.OutputStream.Close();
                        break;
                }
            }
            catch (InvalidOperationException ex) // CRC or data integrity issues from Sht21
            {
                WriteJson(res, 503, $"{{\"status\":\"unavailable\",\"error\":\"{Escape(ex.Message)}\"}}");
            }
            catch (Exception ex)
            {
                WriteJson(res, 500, $"{{\"status\":\"error\",\"error\":\"{Escape(ex.Message)}\"}}");
            }
        }
    }

    static void WriteJson(HttpListenerResponse res, int status, string json)
    {
        byte[] buffer = Encoding.UTF8.GetBytes(json);
        res.StatusCode = status;
        res.ContentType = "application/json";
        res.OutputStream.Write(buffer, 0, buffer.Length);
        res.OutputStream.Close();
    }

    static string Escape(string s) => s.Replace("\\", "\\\\").Replace("\"", "\\\"");
}
