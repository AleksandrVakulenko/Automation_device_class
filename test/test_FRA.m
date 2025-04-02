% Date: 2025.04.02
%
% ----INFO----:
% Test for FRA measurement

% ----TODO----:
% 1) do first run
% 2) seve results func
% ------------

clc

SR860 = SR860_dev(4);
Ammeter = K6517b_dev(27);
% figure('Position', [440  195  665  685]) !!!!!!!!!

try
    SR860.set_advanced_filter("on");
    SR860.set_sync_filter('on');
    SR860.set_detector_phase(0);
    SR860.set_expand(1, "XYR");
    SR860.set_harm_num(1);
    SR860.set_sync_src("INT");
    SR860.set_voltage_input_range(1);
    SR860.set_filter_slope("6 dB/oct");
    SR860.configure_input("VOLT");
    SR860.set_gen_config(0.001, 1e3);
    SR860.set_sensitivity(1, "voltage"); % FIXME: need auto-mode


    Ammeter.config("current");
    Sense = Ammeter.set_sensitivity(3.3e-4, "current");
    Ammeter.enable_feedback("enable");
    adev_utils.Wait(3);

    min_freq = 1; % Hz
    max_freq = 1000; % Hz
    freq_list = 10.^linspace(log10(1), log10(1000), 20);
    freq_list = flip(freq_list);
    Voltage_gen = 1;
    Delta_limit = 0.001;

    figure('Position', [440  195  665  685])

    A_arr = [];
    P_arr = [];
    F_arr = [];
    Timer = tic;
    for i = 1:numel(freq_list)
        time = toc(Timer);

        freq = freq_list(i);
        SR860.set_gen_config(Voltage_gen, freq);
        Period = 1/freq;
        if Period <= 0.02 % FIXME: how to choose tc?
            SR860.set_time_constant(10*Period);
        elseif Period <= 0.05
            SR860.set_time_constant(5*Period);
        else
            SR860.set_time_constant(1.5*Period);
        end
        % -----------------------------------------------
        adev_utils.Wait(Period*0.9);

        stable = false;
        [R_old, Phase_old] = SR860.data_get_R_and_Phase;
        while ~stable
            [Amp, Phase] = SR860.data_get_R_and_Phase;
            Delta_R = Amp - R_old/Amp;
            Delta_Phase = (Phase - Phase_old)/Phase;
            R_old = Amp;
            Phase_old = Phase;
            Delata = abs(Delta_R) + abs(Delta_Phase);
            if Delata < Delta_limit
                stable = true;
            end
            disp(num2str(Delata));
        end
        % -----------------------------------------------
        [Amp, Phase] = SR860.data_get_R_and_Phase;

        Amp = Amp*Sense;

        A_arr = [A_arr Amp];
        P_arr = [P_arr Phase];
        F_arr = [F_arr freq];

        subplot(2, 1, 1)
        cla
        plot(F_arr, A_arr, '-b');
        set(gca, 'xscale', 'log')

        subplot(2, 1, 1)
        cla
        plot(F_arr, P_arr, '-b');
        set(gca, 'xscale', 'log')

        drawnow
    end

catch ERR
    Ammeter.enable_feedback("disable");
    SR860.set_gen_config(0.001, 1e3);
    delete(SR860);
    delete(Ammeter);
    rethrow(ERR);
end

disp("Finished without errors")
disp(['Time passed = ' num2str(time) ' s']);

Ammeter.enable_feedback("disable");
delete(SR860);
delete(Ammeter);



