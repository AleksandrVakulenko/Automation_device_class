
DEBUG_MSG_ENABLE("disable")

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


% FIXME:
% 1) TEST configure_input
% 2) TEST set_current_input_range
% 3) TEST set_voltage_input_range
% 4) TEST get_signal_strength
% 5) TEST set_gen_offset
% 6) TEST set_sync_src
% 7) TEST set_ref_input_impedance


delete(SR860)






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








