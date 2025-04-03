% Date: 2025.04.03
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Stanford Research
% Model: SR844
% Description: RF Lock In Amplifier
% 
% ------------



classdef SR844_dev < aDevice

    methods (Access = public)
        function obj = SR844_dev(GPIB_num)
            arguments
                GPIB_num {adev_utils.GPIB_validation(GPIB_num), ...
                    mustBeMember(GPIB_num, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, ...
                    25, 26, 27, 28, 29, 30])}
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
    
        function Standart_event_status = get_ESR(obj)
            resp = obj.query_and_log("*ESR?");
            resp = dec2bin(num2str(resp), 8);
            data = (resp' == '1');
            Standart_event_status = struct('RXQ', data(1), ...
                'unused1', data(2), 'TXQ', data(3), 'unused3', data(4), ...
                'EXE', data(5), 'CMD', data(6), 'URQ', data(7), ...
                'PON', data(8));
        end

    end

    methods (Access = public)
        function aux_set_voltage(obj, ch_num, value)
            arguments
                obj
                ch_num {mustBeMember(ch_num, [1, 2])}
                value {mustBeInRange(value, -10, 10)}
            end
            CMD = sprintf("AUXV %d, %d", ch_num-1, value);
            obj.send_and_log(CMD);    
        end
        
        function volt = aux_get_voltage(obj, ch_num)
            arguments
                obj
                ch_num {mustBeMember(ch_num, [1, 2])}
            end
            CMD = sprintf("OAUX? %d", ch_num-1);
            resp = obj.query_and_log(CMD);
            resp = str2double(resp);
            volt = adev_utils.round_to_digit(resp, 6); % FIXME 6?
        end
    
        function [X, Y] = data_get_XY(obj)
            CMD = "SNAP? 1, 2";
            resp = obj.query_and_log(CMD);
            data = sscanf(resp, "%f, %f");
            X = data(1);
            Y = data(2);
        end
    
        function [R, Th] = data_get_R_and_Phase(obj)
            CMD = "SNAP? 3, 5";
            resp = obj.query_and_log(CMD);
            data = sscanf(resp, "%f, %f");
            R = data(1);
            Th = data(2);
        end
    end
    
    %------------ SET CMD public block -----------
    methods (Access = public) % SET FUNCTIONS
        function set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, "voltage")} = "voltage";
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

        function set_sync_src(obj, src)
            arguments
                obj
                src {mustBeMember(src, ["INT", "EXT"])}
            end
            CMD = sprintf("RSRC %s", src);
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
                else
                    CMD = "";
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

        function [Xexp, Yexp, Rexp] = get_expand(obj)
            Xexp = obj.query_and_log("CEXP? X");
            Yexp = obj.query_and_log("CEXP? Y");
            Rexp = obj.query_and_log("CEXP? R");
            Xexp = 10^str2double(Xexp);
            Yexp = 10^str2double(Yexp);
            Rexp = 10^str2double(Rexp);
        end
   
        function time_const = get_time_constant(obj)
            resp = obj.query_and_log("OFLT?");
            tc_array = [100e-6, 300e-6, 1e-3, 3e-3, 10e-3, ...
                30e-3, 100e-3, 300e-3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10e3, 30e3];
            time_const = tc_array(str2double(resp)+1);
        end
    
        function time_const = get_time_constant_bad(obj)
            resp = obj.query_and_log("OFLTT?");
            tc_array = [100e-6, 300e-6, 1e-3, 3e-3, 10e-3, ...
                30e-3, 100e-3, 300e-3, 1, 3, 10, 30, 100, 300, 1000, 3000, 10e3, 30e3];
            time_const = tc_array(str2double(resp)+1);
        end

        function NBW = get_filter_NBW(obj)
            resp = obj.query_and_log("ENBW?");
            NBW = str2double(resp);
        end
    end




end




function [sense, ind] = find_best_sensitivity(Level, mode)
arguments
    Level (1,1) double
    mode {mustBeMember(mode, "voltage")} = "voltage"
end
Sens_array_V = [1, 0.3, 0.1, 30e-3, 10e-3, 3e-3, 1e-3, 300e-6, 100e-6, ...
    30e-6, 10e-6, 3e-6, 1e-6, 300e-9, 100e-9];

Sens_array = Sens_array_V;
Limit = 1; % V

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
% model SR844
tc_array = [100e-6, 300e-6, 1e-3, 3e-3, 10e-3, ...
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


