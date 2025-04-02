
DEBUG_MSG_ENABLE("disable")




%% AUTO TEST

clc

SR860 = SR860_dev(4);

% SR860.RESET;

resp = SR860.get_IDN;
disp(['IDN: ' resp])

% set and read volt and freq
v_send = 0.1;
f_send = 1000;
[v_rec, f_rec] = SR860.set_gen_config(v_send, f_send, 0);
assert(v_send == v_rec, "rec gen voltage != send gen voltage");
assert(f_send == f_rec, "rec gen freq != send gen freq");

% read gen volt and freq
[v_rec, f_rec] = SR860.get_genVF;
assert(v_send == v_rec, "rec gen voltage != send gen voltage");
assert(f_send == f_rec, "rec gen freq != send gen freq");

% sensitivity
SR860.set_sensitivity(1, "voltage")

% detector phase
phase_send = 12.345678;
SR860.set_detector_phase(phase_send)
phase_rec = SR860.get_detector_phase;
assert(phase_send == phase_rec, "rec detector phase != send detector phase");

% read detector freq
freq_rec = SR860.get_detector_freq();
% disp(freq_rec)

% harmonic number
harm_n_send = 5;
SR860.set_harm_num(harm_n_send);
harm_n_rec = SR860.get_harm_num();
assert(harm_n_send == harm_n_rec, "rec harm num != send harm num");
SR860.set_harm_num(1);

delete(SR860)

%% MANUAL TEST

% TEST list:
%  1) 
%  2) 
%  3) 
%  4) 
%  5) 
%  6) 
%  7) 
%  8) 
%  9) 
% 10) 
% 11) 
% 12) 
% 13) 

%%
clc
SR860 = SR860_dev(4);

%%
delete(SR860)

%% TEST aux_set_voltage
%  TEST aux_get_voltage
clc
Timer = tic;
Period = 50;

stop = false;
while ~stop
    time = toc(Timer);
    disp(time)
    if time > Period
        stop = true;
    end
    ch1_v = SR860.aux_get_voltage(1);
    SR860.aux_set_voltage(1, ch1_v);
end

%% TEST aux_set_voltage
%  TEST aux_get_voltage
clc
for v = [-10:1:10 0]
    SR860.aux_set_voltage(1, v);
    ch1 = SR860.aux_get_voltage(1);
    disp(ch1)
    pause(0.05);
end

%% TEST set_filter_slope
clc
SR860.set_filter_slope("6 dB/oct");
pause(0.5)
SR860.set_filter_slope("12 dB/oct");
pause(0.5)
SR860.set_filter_slope("18 dB/oct");
pause(0.5)
SR860.set_filter_slope("24 dB/oct");
pause(0.5)

%% TEST set_time_constant
%  TEST get_time_constant
clc
SR860.set_time_constant(0.001);
SR860.get_time_constant;


%% TEST set_expand
%  TEST get_expand
clc
SR860.set_expand(1, "XYR")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])
pause(0.5)
SR860.set_expand(10, "X")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])
pause(0.5)
SR860.set_expand(100, "X")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])
pause(0.5)
SR860.set_expand(10, "Y")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])
pause(0.5)
SR860.set_expand(100, "Y")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])
pause(0.5)
SR860.set_expand(1, "XYR")
[Xexp, Yexp, Rexp] = SR860.get_expand;
disp(['X: ' num2str(Xexp) ' Y:' num2str(Yexp) ' R:' num2str(Rexp)])

%% TEST set_ref_input_impedance
clc
SR860.set_ref_input_impedance("1Meg")
pause(0.5)
SR860.set_ref_input_impedance("50ohms")
pause(0.5)
SR860.set_ref_input_impedance("1Meg")

%% TEST set_sync_src
clc
SR860.set_sync_src("INT")
pause(0.5)
SR860.set_sync_src("EXT")
pause(0.5)
SR860.set_sync_src("INT")

%% TEST set_gen_config
clc
SR860.set_gen_config(0.123, 1.12345, 0.1)

%% TEST set_voltage_input_range
%  TEST get_signal_strength
clc
SR860.set_voltage_input_range(0.01)
SR860.get_signal_strength()
pause(0.5)
SR860.set_voltage_input_range(0.03)
SR860.get_signal_strength()
pause(0.5)
SR860.set_voltage_input_range(0.1)
SR860.get_signal_strength()
pause(0.5)
SR860.set_voltage_input_range(0.3)
SR860.get_signal_strength()
pause(0.5)
SR860.set_voltage_input_range(1)
SR860.get_signal_strength()


%% TEST set_current_input_range
clc
SR860.set_current_input_range("1u")
pause(0.5)
SR860.set_current_input_range("10n")
pause(0.5)
SR860.set_current_input_range("1u")

%% TEST configure_input
clc
SR860.configure_input("VOLT");
pause(0.5)
SR860.configure_input("CURR");
pause(0.5)
SR860.configure_input("VOLT");
















%%

figure

SR860 = SR860_dev(4);

Plot_period = 20; % s
Time_arr = [];
Amp_arr = [];
Freq_arr = [];
Timer = tic;

stop = false;
while ~stop
    time = toc(Timer);
    if time>Plot_period
        stop = true;
    end
    Time_arr = [Time_arr time];
    [Amp, Freq] = SR860.get_genVF;
    Amp_arr = [Amp_arr Amp];

    cla
    plot(Time_arr, Amp_arr)
    set(gca, 'yscale', 'log')
    drawnow
end


delete(SR860)

Time_arr(end)/numel(Time_arr)








