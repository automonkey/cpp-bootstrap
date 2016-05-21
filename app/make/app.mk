STEM := app
TGT_TYPE := cppexe
app_SOURCES :=\
	Main.cpp\

app_DEPENDSON := lib

include rules.mk

