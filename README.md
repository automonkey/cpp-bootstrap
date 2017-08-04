# C++ Makefile Project Bootstrap

Base Makefile setup for a C++ project. All but stolen from a combination of [Igence Ltd.](https://github.com/igence) and [Charles Bailey](https://github.com/hashpling).

Uses the [Catch C++ test framework](https://github.com/philsquared/Catch).

## Basic Usage

`make` build all components and run unit tests.

`make test` to build and run the unit tests.

`make valtest` to run unit tests with memory leak detection using valgrind.

`make clean` to delete output and intermediate files.

## Project Components

***app***: the application (at it's simplest, a wrapper around functionality in *lib*).<br />
***lib***: the unit testable functionality.<br />
***lib-ut***: the unit tests for *lib*.

> It may be desirable to rename *lib* and *lib-ut* to something specific, especially if multiple libs are required.
>
> e.g:<br />
> ***trains-app***<br />
> ***journeyplanning-lib***<br />
> ***journeyplanning-lib-ut***<br />
> ***ticketbookings-lib***<br />
> ***ticketbookings-lib-ut***<br />

## Project layout

```
.
├── Makefile // main project build config (references individual component Makefiles)
├── global.mk // global operation definitions and flags (e.g. compiler flags)
├── rules.mk // rules for building (inc. how to process config from component Makefiles)
├── app
│   ├── impl // C++ app files
│   └── make
│       └── app.mk // app build config (inc. src file list)
├── lib
│   ├── impl // C++ lib files
│   ├── inc  // C++ lib interface (e.g. for app and tests to use)
│   └── make
│       └── lib.mk // lib build config (inc. src file list)
├── lib-ut
│   ├── impl // Unit test definitions
│   └── make
│       └── lib-ut.mk // unit tests build config (inc. src file list)
└── external // External files (including Catch unit test framework)
```