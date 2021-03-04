#pragma once

struct MonitorRect
{
    int width;
    int height;
    int x;
    int y;

    MonitorRect();

    MonitorRect(
        int width,
        int height,
        int x,
        int y);
};
