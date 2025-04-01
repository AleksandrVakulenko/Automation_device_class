
DEBUG_MSG_ENABLE("disable")

% clc




Ammeter = K6517b_dev(27);

% SR860.RESET;

% resp = Ammeter.get_IDN;
% disp(['IDN: ' resp])

% Ammeter.RESET 

% Ammeter.config("current")

% Ammeter.read_last


%%

Ammeter.config("volt")

%%

Ammeter.config("current")


%%

Ammeter.config("charge")

%%
Ammeter.set_zero_check("enable");

%%

Ammeter.set_zero_check("disable");

%%

actual_sense = Ammeter.set_sensitivity(10e-3)

%%
delete(Ammeter)


%%


figure

Ammeter = K6517b_dev(27);

Plot_period = 20; % s
Time_arr = [];
Amp_arr = [];
Freq_arr = [];
Timer = tic;

Ammeter.set_zero_check("disable");

stop = false;
while ~stop
    time = toc(Timer);
    if time>Plot_period
        stop = true;
    end
%     Time_arr = [Time_arr time];
    resp = Ammeter.read_last;
    [a, b]=sscanf(resp, "%eNADC,%esecs,%dRDNG#");
    Amp = a(1);
    time_device = a(2);
    Time_arr = [Time_arr time_device];
    Amp_arr = [Amp_arr Amp];

    cla
    plot(Time_arr-Time_arr(1), Amp_arr*1e15)
    ylabel('I, fA')
    xlabel('t, s')
%     set(gca, 'yscale', 'log')
    drawnow
end

Ammeter.set_zero_check("enable");
delete(Ammeter)












