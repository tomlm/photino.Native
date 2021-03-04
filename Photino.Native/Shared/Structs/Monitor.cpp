#include "Monitor.h"

Monitor::Monitor()
{
    MonitorRect monitor;
    MonitorRect work;

    Monitor(monitor, work);
}

Monitor::Monitor(
    MonitorRect monitor,
    MonitorRect work)
{
    this->monitor = monitor;
    this->work = work;
}
