

tdev = TController2(5);

%%

clc

tdev.Enable_heater

pause(1)

tdev.Disable_heater

%%
clc

[Temp, flags, trigger, stable] = tdev.read_temp;

Temp.temp - 273.15

%%

delete(tdev)

