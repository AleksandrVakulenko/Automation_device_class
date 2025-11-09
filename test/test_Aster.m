

%% Create
clc
Aster = Aster_dev(4);

%% Delete

delete(Aster)

%%

clc

for i = [1:6 1]

Aster.Set_res_feedback(i);
Aster.get_bandwidth
pause(1)

end

%% Read data

Vin = -4.058e-3;
Rin = 1e9;
Vin_div = 1;
Vin = Vin/Vin_div;
Current_in = Vin/Rin;

clc

Aster.set_sensitivity(Current_in);
pause(0.5);

Aster.initiate
pause(0.5);

Period = 60;
Timer = tic;

I_arr = [];
stop = false;
while ~stop
    local_time = toc(Timer);
    disp([num2str(local_time, '%0.2f') ' s'])
    if local_time > Period
        stop = 1;
    end
    [Current, Time_data, OVLD] = Aster.get_current_value;
    I_arr = [I_arr Current];
end
clc

Aster.terminate

figure
plot(I_arr, '-bx');
yline(Current_in, '-r')
yline(Current_in*1.01, '-r')
yline(Current_in*0.99, '-r')

I_meas = mean(I_arr);
% ylim([0.8*I_meas 1.2*I_meas])

I_div = (I_meas - Current_in)/I_meas;
disp([num2str(I_div*100, '%0.3f') ' %'])

%%



%%




%%




%%



Aster.set_current_sensitivity


%%




