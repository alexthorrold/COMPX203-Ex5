#include "wramp.h"

void parallel_main()
{
    // Stores format to display values to SSD in
    int format = 0;

    // Infinitely loops, receiving switch values and sending them to SSD
    for (;;)
    {
        int switches = WrampParallel->Switches;

        if (WrampParallel->Buttons & 1)
        {
            format = 0;
        }
        else if (WrampParallel->Buttons & 2)
        {
            format = 1;
        }
        else if (WrampParallel->Buttons & 4)
        {
            return;
        }

        // Displays base 16
        if (format == 0)
        {
            WrampParallel->UpperLeftSSD = switches >> 12;
            WrampParallel->UpperRightSSD = switches >> 8;
            WrampParallel->LowerLeftSSD = switches >> 4;
            WrampParallel->LowerRightSSD = switches;
        }
        // Displays base 10
        else
        {
            WrampParallel->UpperLeftSSD = (switches / 1000) % 10;
            WrampParallel->UpperRightSSD = (switches / 100) % 10;
            WrampParallel->LowerLeftSSD = (switches / 10) % 10;
            WrampParallel->LowerRightSSD = switches % 10;
        }
    }
}
