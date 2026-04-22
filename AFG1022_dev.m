% Date: 2026.04.20
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Tektronix
% Model: AFG1022
% Description: Function generator
% 
% ------------

% TODO:
% 1) add more functions
% 2) add second channel

classdef AFG1022_dev < aDevice
    properties (Access = private)
        visa_dev = [];
        Serial_number = [];
    end

%--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = AFG1022_dev(Serial_number)
            arguments
                Serial_number = []
            end
            [vias_adr, SN] = con_utils.find_visa_dev_by_name("AFG1022", Serial_number);
            obj@aDevice(Connector_VISA(vias_adr));
            obj.Serial_number = SN;
        end

        function sn = get_serial_number(obj)
            sn = obj.Serial_number;
        end

        function response = IDN(obj)
            response = obj.query_and_log("*IDN?");
            response = strtrim(response);
        end

        function initiate(obj)
            CMD = 'OUTPut1:STATe ON';
            obj.send_and_log(CMD);
        end

        function terminate(obj)
            CMD = 'OUTPut1:STATe OFF';
            obj.send_and_log(CMD);
        end

        function freq = set_freq(obj, freq_in)
            CMD = ['SOURCE1:FREQUENCY:FIXED ' num2str(freq_in) ' Hz'];
            obj.send_and_log(CMD);
            resp = obj.query_and_log('SOURCE1:FREQUENCY:FIXED?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                freq = data(1);
            end
        end

        function amp = set_amp(obj, amp, type)
            arguments
                obj
                amp double
                type {mustBeMember(type, ["amp", "Ap-p"])} = "amp"
            end
            if type == "amp"
                amp = amp * 2;
            end
            CMD = ['SOURce1:VOLTage:LEVel:IMMediate:AMPLitude ' num2str(amp) ' Vpp'];
            obj.send_and_log(CMD);
            resp = obj.query_and_log('SOURce1:VOLTage:LEVel:IMMediate:AMPLitude?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                amp = data(1);
            end
        end

        function offset = set_offset(obj, offset)
            arguments
                obj
                offset double
            end
            CMD = ['SOURce1:VOLTage:LEVel:IMMediate:OFFSet ' num2str(offset) ' V'];
            obj.send_and_log(CMD);
            resp = obj.query_and_log('SOURce1:VOLTage:LEVel:IMMediate:OFFSet?');
            resp = strtrim(resp);
            data = sscanf(resp, '%f');
            if ~isempty(data)
                offset = data(1);
            end
        end     

        function shape = set_func(obj, shape)
            arguments
                obj
                shape {mustBeMember(shape, ["sin", "sq", "triangle"])}
            end
            if shape == "sin"
                shape = 'SINusoid';
            end
            if shape == "sq"
                shape = 'SQUare';
            end
            if shape == "triangle"
                shape = 'RAMP';
            end
            CMD = ['SOURce1:FUNCtion:SHAPe ' shape];
            obj.send_and_log(CMD);
            shape = obj.query_and_log('SOURce1:FUNCtion:SHAPe?');
            shape = strtrim(shape);
        end  

    end

end









