using System.Device.I2c;

public class Sht21
{
    private readonly I2cDevice device;

    // I2C address of SHT21
    private const byte Address = 0x40;

    // Commands
    private const byte TriggerTempNoHold = 0xF3;
    private const byte TriggerHumNoHold  = 0xF5;

    public Sht21(I2cDevice dev) => device = dev;

    public double ReadTemperatureC()
    {
        ushort raw = ReadRaw(TriggerTempNoHold, maxWaitMs: 85);
        return -46.85 + (175.72 * raw / 65536.0);
    }

    public double ReadHumidityPercent()
    {
        ushort raw = ReadRaw(TriggerHumNoHold, maxWaitMs: 29);
        return -6.0 + (125.0 * raw / 65536.0);
    }

    private ushort ReadRaw(byte command, int maxWaitMs)
    {
        device.WriteByte(command);
        Thread.Sleep(maxWaitMs);

        Span<byte> buf = stackalloc byte[3]; // MSB, LSB, CRC
        device.Read(buf);

        ushort raw = (ushort)((buf[0] << 8) | buf[1]);
        
        raw &= 0xFFFC; // clear status bits

        if (!CheckCrc(raw, buf[2]))
            throw new InvalidOperationException("CRC check failed");

        return raw;
    }

    private static bool CheckCrc(ushort value, byte checksum)
    {
        byte crc = 0;
        byte[] data = { (byte)(value >> 8), (byte)(value & 0xFF) };

        foreach (byte b in data)
        {
            crc ^= b;
            for (int i = 0; i < 8; i++)
                crc = (byte)((crc & 0x80) != 0 ? (crc << 1) ^ 0x131 : crc << 1);
        }

        return crc == checksum;
    }
}
