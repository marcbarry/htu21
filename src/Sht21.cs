using System.Device.I2c;

public class Sht21
{
    private readonly I2cDevice device;

    // I2C address of SHT21
    private const byte Address = 0x40;

    // Commands
    private const byte TriggerTempNoHold = 0xF3;
    private const byte TriggerHumNoHold  = 0xF5;

    // CRC-8 polynomial for SHT2x over I2C: x^8 + x^5 + x^4 + 1
    // See Sensirion CRC application note at https://sensirion.com/media/documents/2AAE8D8E/6163FAB3/Sensirion_Humidity_Sensors_SHT2x_CRC_Calculation.pdf
    private const int CrcPolynomial = 0x131; 

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

        if (!CheckCrc(buf.Slice(0, 2), buf[2]))
            throw new InvalidOperationException("CRC check failed");

        return raw;
    }

    // CRC-8 over data bytes with polynomial 0x131 (x^8 + x^5 + x^4 + 1), init 0x00, no final XOR
    private static bool CheckCrc(ReadOnlySpan<byte> data, byte checksum)
    {
        byte crc = 0;
        foreach (byte b in data)
        {
            crc ^= b;
            for (int i = 0; i < 8; i++)
                crc = (byte)(((crc & 0x80) != 0) ? ((crc << 1) ^ CrcPolynomial) : (crc << 1));
        }
        return crc == checksum;
    }
}
