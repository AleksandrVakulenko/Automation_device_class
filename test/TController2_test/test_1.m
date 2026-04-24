
clc
figure
hold on


controller = TController2('COM3');
controller.Enable_heater;
controller.Set_setpoint(298);
controller.Set_ramp(310, 10);


Period = 500; %s

flag = 0;
i = 0;
time = [];
temp = [];
temp_sp = [];
temp_gsp = [];
power = [];
lock = [];
ramping = [];
Timer = tic;
while toc(Timer) < Period
i = i + 1;

[Temp, flags, trigger] = controller.read_temp();

time(i) = toc(Timer);
temp(i) = Temp.temp;
temp_sp(i) = Temp.sp;
temp_gsp(i) = Temp.gsp;
power(i) = Temp.power;
lock(i) = flags.lock;
ramping(i) = flags.ramping;

cla
plot(time, temp, 'b')
plot(time, temp_sp, 'r')
plot(time, temp_gsp, 'g')


if toc(Timer) > 105 & flag == 0
flag = 1;
controller.Set_ramp(320, 30);
end

if toc(Timer) > 160 & flag == 1
flag = 2;
controller.Set_ramp(310, 10);
end

if toc(Timer) > 260 & flag == 2
flag = 3;
controller.Set_ramp(300, 5);
end

if toc(Timer) > 320 & flag == 3
flag = 4;
controller.Set_ramp(370, 50);
end

if toc(Timer) > 415 & flag == 4
flag = 5;
controller.Set_ramp(300, 50);
end

end


controller.Set_setpoint(273);
controller.Disable_heater();
delete(controller)

