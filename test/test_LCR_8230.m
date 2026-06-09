%% PART 1: basic functions

clc

GPIB_adr = -1; % FIXME
Vac = 0.678; % V
Freq = 1234.567; % Hz

lcr_dev = LCR_8230(GPIB_adr);

try
    lcr_dev.initiate;
    lcr_dev.set_measure_speed("fast");
    lcr_dev.set_amplitude(Vac);
    lcr_dev.set_freq(Freq);
    
    IDN_resp = lcr_dev.get_IDN;
    disp('IDN response:');
    disp(IDN_resp);
    disp(' ')
    
    [VAC, IAC] = lcr_dev.get_v_i_ac;
    disp(['AC voltage = ' num2str(VAC), ' V'])
    disp(['AC current = ' num2str(IAC), ' A'])
    disp(' ')
    
    [RDC, Z, DEG, resp] = lcr_dev.measure_and_read();
    disp(['response: <' resp '>'])
    disp(['R(DC) = ' num2str(RDC), ' Ohm'])
    disp(['|Z| = ' num2str(Z), ' Ohm'])
    disp(['Phase = ' num2str(DEG), ' deg'])
    disp(' ')

catch err
    lcr_dev.delete;
    rethrow(err);

end

lcr_dev.terminate;
lcr_dev.delete;




%% PART 2: FRA

addpath(genpath('FRA_utils/'));

%--------------------------
Vac = 0.5; % V
Freq_min = 100; % Hz
Freq_max = 10e6; % Hz
Freq_count = 100;
Freq_permutation = false;
%--------------------------

freq_list = freq_list_gen(Freq_min, Freq_max, Freq_count, Freq_permutation);

lcr_dev = LCR_8230(GPIB_adr);
try
    lcr_dev.initiate;
    lcr_dev.set_measure_speed("fast");
    lcr_dev.set_amplitude(Vac);
    
    Data = FRA_data('R, [Ohm]');
    Fig = FRA_plot(freq_list, 'Z, Ohm', 'Phase, °');
    
    Timer = tic();
    N = numel(freq_list);
    for i = 1:N
        freq = freq_list(i);
        lcr_dev.set_freq(freq);
        time = toc(Timer);
    
        disp([num2str(i) '/' num2str(N)])
        disp(['f = ' num2str(freq) ' Hz'])
        disp(['time passed: ' num2str(time, '%.1f') ' s'])
        disp(' ')
        
        [~, Z, DEG] = lcr_dev.measure_and_read();
        
        Data.add(freq, "R", Z, "Phi", DEG);
        Fig.replace_FRA_data(Data);
    end

catch err
    lcr_dev.delete;
    rethrow(err);
end
lcr_dev.terminate;
lcr_dev.delete;



%% Other test


clc

lcr_dev = LCR_E4980AL();
disp('Connected')
disp(['Serial number: ' char(lcr_dev.get_serial_number)])
disp(' ')

lcr_dev.set_measurment_function("Cp-G");

lcr_dev.set_speed("short", 1)
lcr_dev.set_volt(1);
lcr_dev.set_freq(20e3);

lcr_dev.set_measurment_function("Z-thd");
[A, B] = lcr_dev.get_readings()

% [R1, R2] = lcr_dev.get_res
[C, D] = lcr_dev.get_cap
[C, D] = lcr_dev.get_cap
[C, D] = lcr_dev.get_cap


delete(lcr_dev)
disp(' ')
disp('Deleted')
