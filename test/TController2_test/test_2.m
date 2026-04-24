



clc
figure
hold on

% init temp controller
controller = TController2('COM5');
controller.Enable_heater;
controller.feedback('off');
controller.feedback('on');


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
stable = [];
Timer = tic;

stop = 0;
controller.Set_ramp(273.15 + 70, 5);
while ~stop
i = i + 1;

[Temp, flags, trigger, stable_fl] = controller.read_temp();

time(i) = toc(Timer);
temp(i) = Temp.temp;
temp_sp(i) = Temp.sp;
temp_gsp(i) = Temp.gsp;
power(i) = Temp.power;
lock(i) = flags.lock;
ramping(i) = flags.ramping;
stable(i) = stable_fl;

cla
plot(time, temp, 'b')
plot(time, temp_sp, 'r')
plot(time, temp_gsp, 'g')


if (toc(Timer) > 1800 || stable_fl == 1) && flag == 0
    flag = 1;
    controller.Set_ramp(290, 5);
end

if temp_sp(i) < 295 && flag == 1
    stop = 1;
end

end


controller.Set_setpoint(273);
controller.Disable_heater();
delete(controller)

%%

plot(abs(temp_sp - temp))
set(gca, 'yscale', 'log')















