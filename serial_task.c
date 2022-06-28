#include "wramp.h"

int counter = 0;

void putchar(char c)
{
    while (!(WrampSp2->Stat & 2));
    WrampSp2->Tx = c;
}

void serial_main()
{
    char format = '1';

    // Infinitely loops, writing current timer in selected format to serial port 2
    for (;;)
    {
        // Changes format if an input has been received in serial port 2
        if (WrampSp2->Stat & 1)
        {
            char c = WrampSp2->Rx;

            if (c == '1' || c == '2' || c == '3' || c == 'q')
            {
                format = c;
            }
        }

        if (format == 'q')
        {
            return;
        }

        putchar('\r');

        // Format \rmm:ss
        if (format == '1')
        {
            putchar(((counter / 6000) / 10) % 10 + '0');
            putchar((counter / 6000) % 10 + '0');
            putchar(':');
            putchar(((counter % 6000) / 1000) % 10 + '0');
            putchar(((counter % 6000) / 100) % 10 + '0');
            // space characters to clear longer char length formats
            putchar(' ');
            putchar(' ');
        }
        // Format \rssss.ss
        else if (format == '2')
        {
            putchar((counter / 100000) % 10 + '0');
            putchar((counter / 10000) % 10 + '0');
            putchar((counter / 1000) % 10 + '0');
            putchar((counter / 100) % 10 + '0');
            putchar('.');
            putchar((counter / 10) % 10 + '0');
            putchar(counter % 10 + '0');
        }
        // Format \rtttttt
        else
        {
            putchar((counter / 100000) % 10 + '0');
            putchar((counter / 10000) % 10 + '0');
            putchar((counter / 1000) % 10 + '0');
            putchar((counter / 100) % 10 + '0');
            putchar((counter / 10) % 10 + '0');
            putchar(counter % 10 + '0');
            putchar(' '); // space character to clear longer char length formats
        }
    }
}
