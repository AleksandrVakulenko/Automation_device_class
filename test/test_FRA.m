

clc

SR860 = SR860_dev(4);

freq_list = 10.^linspace(log10(1), log10(1000), 20);
Voltage_gen = 1;

Time_arr = [];
R_arr = [];
P_arr = [];
Timer = tic;

stop = false;
for i = 1:numel(freq_list)
    time = toc(Timer);
    Time_arr = [Time_arr time];

    freq = freq_list(i);
    SR860.set_gen_config(Voltage_gen, freq);
    Period = 1/freq;
    pause(Period*0.8);

    stable = false;
    [R_old, Phase_old] = SR860.data_get_R_and_Phase;
    while ~stable
        [R, Phase] = SR860.data_get_R_and_Phase;

    end


    cla
    plot(R_arr, P_arr);
    set(gca, 'yscale', 'log')
    drawnow
end


delete(SR860);

