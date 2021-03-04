#include "MonitorRect.h"

MonitorRect::MonitorRect()
{
    MonitorRect(0, 0, 0, 0);
}

MonitorRect::MonitorRect(
    int width,
    int height,
    int x,
    int y)
{
    this->width = width;
    this->height = height;
    this->x = x;
    this->y = y;
}