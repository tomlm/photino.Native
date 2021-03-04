#pragma once
#include "MonitorRect.h"

struct Monitor
{
	MonitorRect monitor, work;

    Monitor();

    Monitor(
        MonitorRect monitor,
        MonitorRect work);
};
