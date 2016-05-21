#include "catch.hpp"

#include "Lib-AppUsageStringGeneration.h"

#include <iostream>
#include <sstream>
#include <string>

TEST_CASE( "Generate correct usage string", "[will]" ) {
    std::ostringstream usageString;

    Lib::OutputAppUsageString( usageString );

    REQUIRE(
        usageString.str() ==
        "usage: app\nFunctionality yet to be defined...\n"
    );
}

