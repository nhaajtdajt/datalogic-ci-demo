#include <stdio.h>

#include "sensor.h"

int main(void)
{
    printf("Embedded Linux training: %d C\n", sensor_temperature_c());
    return 0;
}
