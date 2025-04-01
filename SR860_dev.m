% Date: 2025.04.01
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Stanford Research
% Model: SR830
% Description: Lock In Amplifier
% 
% ------------

% TODO:

% 13) SYNC p113
% 14) ADVFILT
% 22) ENBW?

% 20) OUTP? (!!!!) p132
% 21) SNAP? (!!!)

% 18) OAUX (!) p116
% 19) AUXV (!)




% 16) COFA p114
% 17) COFP

% 22) Data Streaming Commands ? p140





classdef SR860_dev < aDevice

    methods (Access = public)
        function obj = SR860_dev(GPIB_num)
            arguments
                % FIXME: maybe list of values?
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB_fast(GPIB_num))
        end
    end

    %---------- COMMON CMD public block ----------
    methods (Access = public)
        function RESET(obj)
            obj.send_and_log("*RST");
        end

        function resp = get_IDN(obj)
            resp = obj.query_and_log("*IDN?");
        end
    end

    
    %------------ SET CMD public block -----------
    methods (Access = public) % SET FUNCTIONS
        function set_gen_config(obj, amp_V, freq_Hz, offset)
            arguments
                obj
                amp_V (1, 1) double {mustBeNumeric(amp_V), ...
                    mustBeInRange(amp_V, 1e-9, 2, "inclusive")}
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
                offset (1, 1) double {mustBeNumeric(offset), ...
                    mustBeInRange(offset, -5, 5, "inclusive")} = 0
            end
            obj.set_gen_freq(freq_Hz);
            obj.set_gen_amp(amp_V);
            obj.set_gen_offset(offset);
        end

        function set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, ["voltage", "current"])}
            end
            [~, ind] = find_best_sensitivity(Level, mode);
            CMD = sprintf("SCAL %d", ind);
            obj.send_and_log(CMD);
        end

        function set_detector_phase(obj, phase_deg)
            arguments
                obj
                phase_deg (1, 1) double {mustBeNumeric(phase_deg), ...
                    mustBeInRange(phase_deg, -360e3, 360e3, "inclusive")}
            end
            CMD = sprintf("PHAS %0.7d DEG", phase_deg);
            obj.send_and_log(CMD);
        end

        function set_harm_num(obj, harm_n)
            arguments
                obj
                harm_n (1,1) {mustBeNumeric(harm_n), ...
                    mustBeInRange(harm_n, 1, 99, "inclusive")}
            end
            if  harm_n ~= round(harm_n)
                harm_n = round(harm_n);
                warning(['Harmonic number rounded to ' num2str(harm_n)]);
            end
            CMD = sprintf("HARM %d", harm_n);
            obj.send_and_log(CMD);
        end

        function set_current_input_range(obj, curr_range)
            arguments
                obj
                curr_range {mustBeMember(curr_range, "1u", "10n")}
            end
            switch curr_range
                case "1u"
                    Text = "1MEG";
                case "10n"
                    Text = "100MEG";
                otherwise
                    error('placeholder') % FIXME
            end
            CMD = spritntf("ICUR %s", Text);
            obj.send_and_log(CMD);
        end

        function set_voltage_input_range(obj, volt_range)
            arguments
                obj
                volt_range {mustBeMember(volt_range,...
                    [1, 0.3, 0.1, 0.03, 0.010])} = 1;
            end
            switch volt_range
                case 1.000
                    Text = "1V";
                case 0.300
                    Text = "300M";
                case 0.100
                    Text = "100M";
                case 0.030
                    Text = "30M";
                case 0.010
                    Text = "10M";
                otherwise
                    error('placeholder') % FIXME
            end
            CMD = spritntf("IRANG %s", Text);
            obj.send_and_log(CMD);
        end

        function configure_input(obj, input_mode)
            arguments
                obj
                input_mode {mustBeMember(input_mode, ["VOLT", "CURR"])};

            end
            CMD_1 = sprintf("IVMD %s", input_mode);
            CMD_2 = "ISRC A"; % NOTE:  always A(V) (not A-B)
            CMD_3 =  "ICPL DC"; % NOTE:  always DC(V) mode
            CMD_4 = "IGND GROund";  % NOTE:  always ground mode
            CMD = CMD_1 +";" + CMD_2 +";" + CMD_3 +";" + CMD_4;
            obj.send_and_log(CMD);
        end

        function set_sync_src(obj, src)
            arguments
                obj
                src {mustBeMember(src, ["INT", "EXT"])}
            end
            CMD = spritnf("RSRC %s", src);
            obj.send_and_log(CMD);
        end

        function set_ref_input_impedance(obj, R)
            arguments
                obj
                R {mustBeMember(R, ["50ohms", "1Meg"])}
            end
                CMD = sprintf("REFZ %s", R);
                obj.send_and_log(CMD);
        end
    
        function set_expand(obj, exp_value, out_ch)
            arguments
                obj
                exp_value (1,1) {mustBeMember(exp_value, [1, 10, 100])}
                out_ch (1,1) {mustBeMember(out_ch, ...
                    ["XYR", "X", "Y", "XY", "R"])} = "XYR"
            end
                Contains = @(str1, str2) ...
                    ~isempty(find(char(str1) == char(str2), 1));

                switch exp_value
                    case 1
                        exp_mode = 0;
                    case 10
                        exp_mode = 1;
                    case 100
                        exp_mode = 2;
                end

                if Contains(out_ch, "X")
                    CMD = sprintf("CEXP X, %d", exp_mode);
                end
                if Contains(out_ch, "Y")
                    CMD2 = sprintf("CEXP Y, %d", exp_mode);
                    CMD = CMD + ";" + CMD2;
                end
                if Contains(out_ch, "R")
                    CMD2 = sprintf("CEXP R, %d", exp_mode);
                    CMD = CMD + ";" + CMD2;
                end
                obj.send_and_log(CMD);
        end

        function time_const = set_time_constant(obj, time_const)
            arguments
                obj
                time_const (1,1) {mustBeNumeric(time_const), ...
                    mustBeInRange(time_const, 1e-6, 30e3)}
            end
                [time_const, ind] = find_best_time_constant(time_const);
                CMD = sprintf("OFLT %d", ind);
                obj.send_and_log(CMD);
        end

        function set_filter_slope(obj, slope)
            arguments
                obj
                slope (1,1) {mustBeMember(slope, ["6 dB/oct", "12 dB/oct", ...
                    "18 dB/oct", "24 dB/oct"])}
            end
                switch slope
                    case "6 dB/oct"
                        num = 0;
                    case "12 dB/oct"
                        num = 1;
                    case "18 dB/oct"
                        num = 2;
                    case "24 dB/oct"
                        num = 3;
                end
                CMD = sprintf("OFSL %d", num);
                obj.send_and_log(CMD);
        end
    end


    %------------ GET CMD public block -----------
    methods (Access = public) % GET FUNCTIONS
        function [amp_V, freq_Hz] = get_genVF(obj)
            amp_V = obj.get_gen_amp();
            freq_Hz = obj.get_gen_freq();
        end

        function phase_deg = get_detector_phase(obj)
            CMD = "PHAS?";
            resp = obj.query_and_log(CMD);
            phase_deg = str2double(resp);
            phase_deg = adev_utils.round_to_digit(phase_deg, 6);
        end

        function freq_Hz = get_detector_freq(obj)
            CMD = "FREQ?";
            resp = obj.query_and_log(CMD);
            freq_Hz = str2double(resp);
            freq_Hz = adev_utils.round_to_digit(freq_Hz, 4);
        end

        function harm_num = get_harm_num(obj)
            CMD = "HARM?";
            resp = obj.query_and_log(CMD);
            harm_num = str2double(resp);
        end

        function value = get_signal_strength(obj)
            CMD = "ILVL?";
            resp = obj.query_and_log(CMD);
            value = str2double(resp);
        end
    
        function [Xexp, Yexp, Rexp] = get_expand(obj)
            Xexp = obj.query_and_log("CEXP? X");
            Yexp = obj.query_and_log("CEXP? Y");
            Rexp = obj.query_and_log("CEXP? R");
            % FIMXE: resp format?
        end
   
        function time_const = get_time_constant(obj)
            resp = obj.query_and_log("OFLT ?");
            time_const = str2double(resp);
            time_const = adev_utils.round_to_digit(time_const, 6);
        end
    end


    %----------- CMD PRIVATE block -----------
    methods (Access = private) % FIXME: make private (done)
        function set_gen_freq(obj, freq_Hz)
            arguments
                obj
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
            end
            CMD = sprintf("FREQINT %f HZ", freq_Hz);
            obj.send_and_log(CMD);
        end

        function set_gen_amp(obj, amp_V)
            arguments
                obj
                amp_V (1, 1) double {mustBeNumeric(amp_V), ...
                    mustBeInRange(amp_V, 1e-9, 2, "inclusive")}
            end
            CMD = sprintf("SLVL %0.3f V", amp_V);
            obj.send_and_log(CMD);
        end

        function set_gen_offset(obj, offset)
            arguments
                obj
                offset (1, 1) double {mustBeNumeric(offset), ...
                    mustBeInRange(offset, -5, 5, "inclusive")}
            end
            CMD = sprintf("SOFF %0.3f V", offset);
            obj.send_and_log(CMD);
        end

        function freq_Hz = get_gen_freq(obj)
            CMD = "FREQINT?";
            resp = obj.query_and_log(CMD);
            freq_Hz = str2double(resp);
            freq_Hz = adev_utils.round_to_digit(freq_Hz, 4);
        end

        function amp_V = get_gen_amp(obj)
            CMD = "SLVL?";
            resp = obj.query_and_log(CMD);
            amp_V = str2double(resp);
            amp_V = adev_utils.round_to_digit(amp_V, 8);
        end

    end
    %-----------------------------------------

end



% FIXME: delete unsued func
function out = set_argout(n_out, varargin)
n_in = nargin-1;
if n_out > 0
    if n_in <= n_out
        for i = 1:n_in
            out{i} = varargin{i};
        end
        for i = n_in+1:n_out
            out{i} = [];
        end
    else % n_in > n_out
        for i = 1:n_out
            out{i} = varargin{i};
        end
    end
else
    out = {};
end
end


function [sense, ind] = find_best_sensitivity(Level, mode)
arguments
    Level (1,1) double
    mode {mustBeMember(mode, ["voltage", "current"])}
end
Sens_array_V = [1, 500e-3, 200e-3, 100e-3, 50e-3, 20e-3, ...
    10e-3, 5e-3, 2e-3, 1e-3, 500e-6, 200e-6, 100e-6, 50e-6, ...
    20e-6, 10e-6, 5e-6, 2e-6, 1e-6, 500e-9, 200e-9, 100e-9, ...
    50e-9, 20e-9, 10e-9, 5e-9, 2e-9, 1e-9];
Sens_array_I = Sens_array_V/1e6;
switch mode
    case "voltage"
        Sens_array = Sens_array_V;
        Limit = 1; % V
    case "current"
        Sens_array = Sens_array_I;
        Limit = 1e-6; % A
end
if Level > Limit*1.1
    warning("Level of sensitivity is above maximum")
    Level = Limit;
end
ind = find(Sens_array<Level, 1);
if isempty(ind)
    ind = numel(Sens_array);
elseif ind > 1
    ind = ind - 1;
end
sense = Sens_array(ind);
ind = ind - 1;
end

function [time_const, ind] = find_best_time_constant(time_const)
tc_array = [1e-6, 3e-6, 10e-6, 30e-6, 100e-6, 300e-6, 1e-3, 3e-3, 10e-3, ...
    30e-3, 100e-3, 300e-3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10e3, 30e3];

Min_tc = tc_array(1);
Max_tc = tc_array(end);
if time_const < Min_tc
    time_const = Min_tc;
end
if time_const > Max_tc
    time_const = Max_tc
end

[~, ind] = min(abs(tc_array-time_const));
time_const = tc_array(ind);
ind = ind - 1;

end





