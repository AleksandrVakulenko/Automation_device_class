% Date: 2026.04.20
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Keysight
% Model: E4980
% Description: LCR meter
% 
% ------------


classdef LCR_E4980AL < aDevice
    properties(Access = private)
        Serial_number = [];
    end

    %--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = LCR_E4980AL(Serial_number)
            arguments
                Serial_number = []
            end
            [vias_adr, SN] = con_utils.find_visa_dev_by_name("E4980AL", ...
                Serial_number, ["USB", "GPIB"]);
            if isempty(vias_adr) % FIXME: is it enought? need validation
                error('connection error');
            end
            obj@aDevice(Connector_VISA(vias_adr));
            obj.Serial_number = SN;
        end
    
        function sn = get_serial_number(obj)
            sn = obj.Serial_number;
        end

        function volt_out = set_volt(obj, volt_in)
            arguments
                obj
                volt_in {mustBeInRange(volt_in, 0, 2, "inclusive")}
            end
            obj.send_and_log([':VOLTage:LEVel ' num2str(volt_in)]);
            response = obj.query_and_log(':VOLTage:LEVel?');
            data = sscanf(response, '%f');
            volt_out = data(1);
        end


        function freq_out = set_freq(obj, freq_in)
            % NOTE: freq limit for model E4980AL
            arguments
                obj
                freq_in {mustBeInRange(freq_in, 20, 300000, "inclusive")}
            end
            obj.send_and_log([':FREQuency:CW ' num2str(freq_in)]);
            response = obj.query_and_log(':FREQuency:CW?');
            data = sscanf(response, '%f');
            freq_out = data(1);
        end

        function [A, B] = get_readings(obj)
            response = obj.query_and_log(':FETCh:IMPedance:FORmatted?');
            data = sscanf(response, '%f,%f');
            A = data(1);
            B = data(2);
        end

        function [res_re, res_im] = get_res(obj)
            response = obj.query_and_log(':FETCh:IMPedance:CORrected?');
            data = sscanf(response, '%f,%f');
            res_re = data(1);
            res_im = data(2);
        end


        function [cap_re, tan_d] = get_cap(obj, mode)
            arguments
                obj
                mode {mustBeMember(mode, ["series", "parallel"])} = "parallel"
            end
            if mode == "series"
                new_mode = "Cs-D";
            else
                new_mode = "Cp-D";
            end
            prev_mode = obj.get_measurment_function();
            if string(prev_mode) ~= string(mode2cmd(new_mode))
                obj.set_measurment_function(new_mode);
                response = obj.query_and_log(':FETCh:IMPedance:FORmatted?');
                CMD = [':FUNCtion:IMPedance:TYPE ' char(prev_mode)];
                obj.send_and_log(CMD);
            else
                response = obj.query_and_log(':FETCh:IMPedance:FORmatted?');
            end
            
            data = sscanf(response, '%f,%f');
            cap_re = data(1);
            tan_d = data(2);
        end


        function set_measurment_function(obj, mode)
            arguments
                obj
                mode {mustBeMember(mode, ["Cp-D", "Cp-Q", "Cp-G", "Cp-Rp", ...
                    "Cs-D", "Cs-Q", "Cs-Rs", "Lp-D", "Lp-Q", "Lp-G", ...
                    "Lp-Rp", "Ls-D", "Ls-Q", "Ls-Rs", "R-X", "Z-thd", ...
                    "Z-thr", "G-B", "Y-thd", "Y-thr", "Vdc-Idc", ...
                    "Lp-Rdc", "Ls-Rdc"])}
            end
            CMD_part = mode2cmd(mode);
            CMD = [':FUNCtion:IMPedance:TYPE ' char(CMD_part)];
            obj.send_and_log(CMD);
        end

        function mode = get_measurment_function(obj)
            resp = obj.query_and_log(':FUNCtion:IMPedance?');
            mode = strtrim(resp);
        end

        function set_speed(obj, mode, count)
            % FIXME: find limit on count value
            % NOTE: "s", "m", "l" modes are legacy
            arguments
                obj
                mode string {mustBeMember(mode, ["s", "m", "l", ...
                    "short", "medium", "long"])} = "medium"
                count {mustBeInteger(count)} = 2;
            end
            if mode == "s"
                mode = "short";
            end
            if mode == "m"
                mode = "medium";
            end
            if mode == "l"
                mode = "long";
            end
            count = uint8(count);
            switch lower(mode)
                case "short"
                    CMD = [':APERture SHORt, ' num2str(count)];
                case "medium"
                    CMD = [':APERture MEDium, ' num2str(count)];
                case "long"
                    CMD = [':APERture LONG, ' num2str(count)];
                otherwise
                    error('unreachable')
            end
            obj.send_and_log(CMD);
        end


    end
    
end


%NOTE:
% list of functions
% CPD   -  "Cp-D"
% CPQ   -  "Cp-Q"
% CPG   -  "Cp-G"
% CPRP  -  "Cp-Rp"

% CSD   -  "Cs-D"
% CSQ   -  "Cs-Q"
% CSRS  -  "Cs-Rs"
% LPD   -  "Lp-D"
% LPQ   -  "Lp-Q"
% LPG   -  "Lp-G"
% LPRP  -  "Lp-Rp"
% LSD   -  "Ls-D"
% LSQ   -  "Ls-Q"
% LSRS  -  "Ls-Rs"
% RX    -  "R-X"
% ZTD   -  "Z-thd"
% ZTR   -  "Z-thr"
% GB    -  "G-B"
% YTD   -  "Y-thd"
% YTR   -  "Y-thr"
% VDID  -  "Vdc-Idc"

% LPRD  -  "Lp-Rdc" *1
% LSRD  -  "Ls-Rdc" *1
%
% *1: This can be set only when option 001, 030, 050, 100 or 200 is installed.


function CMD = mode2cmd(mode)
arguments
    mode {mustBeMember(mode, ["Cp-D", "Cp-Q", "Cp-G", "Cp-Rp", "Cs-D", ...
        "Cs-Q", "Cs-Rs", "Lp-D", "Lp-Q", "Lp-G", "Lp-Rp", "Ls-D", "Ls-Q", ...
        "Ls-Rs", "R-X", "Z-thd", "Z-thr", "G-B", "Y-thd", "Y-thr", ...
        "Vdc-Idc", "Lp-Rdc", "Ls-Rdc"])}
end

switch mode
    case "Cp-D"
        CMD = "CPD";
    case "Cp-Q"
        CMD = "CPQ";
    case "Cp-G"
        CMD = "CPG";
    case "Cp-Rp"
        CMD = "CPRP";
    case "Cs-D"
        CMD = "CSD";
    case "Cs-Q"
        CMD = "CSQ";
    case "Cs-Rs"
        CMD = "CSRS";
    case "Lp-D"
        CMD = "LPD";
    case "Lp-Q"
        CMD = "LPQ";
    case "Lp-G"
        CMD = "LPG";
    case "Lp-Rp"
        CMD = "LPRP";
    case "Ls-D"
        CMD = "LSD";
    case "Ls-Q"
        CMD = "LSQ";
    case "Ls-Rs"
        CMD = "LSRS";
    case "R-X"
        CMD = "RX";
    case "Z-thd"
        CMD = "ZTD";
    case "Z-thr"
        CMD = "ZTR";
    case "G-B"
        CMD = "GB";
    case "Y-thd"
        CMD = "YTD";
    case "Y-thr"
        CMD = "YTR";
    case "Vdc-Idc"
        CMD = "VDID";

    case "Lp-Rdc"
        CMD = "LPRD";
    case "Ls-Rdc"
        CMD = "LSRD";
    otherwise
        error('unreachable')
end
end

















