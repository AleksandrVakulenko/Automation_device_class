% Date: 2025.11.09
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: NCM lab
% Model: Aster
% Description: Current to voltage converter
%
% ------------

% TODO:
%  1) 
%  2) 
%  3)

classdef Aster_dev < aDevice & I2V_converter_traits
    properties (Access = private)
        FB_res
        bandwidth
    end

    methods (Access = public)
        function obj = Aster_dev(COM_port_N)
            arguments
                COM_port_N {mustBeNumeric(COM_port_N)}
            end
            COM_port_name = string(['COM' num2str(COM_port_N)]);
            obj@aDevice(Connector_COM_USB(COM_port_name));
            pause(0.1);
            obj.init_device();
        end

        function resp = get_IDN(obj)
            warning("*IDN? cmd is not supported");
            resp = "*IDN? cmd is not supported";
        end
   
%         function delete(obj)
%             try
%                 obj.terminate();
%             catch
%                 disp("Error in Aster d-tor");
%             end
%         end
    end


    %--------- DATA READ CMD public block --------
    methods (Access = public)

    end


    %------------ SET CMD public block -----------
    methods (Access = public)
        function [sense, BW] = set_sensitivity(obj, Level)
            arguments
                obj
                Level (1,1) double
            end
            Sense_array = [25e-3 500e-6 5e-6 50e-9 500e-12 5e-12];
            ind = find(Level <= Sense_array);
            if isempty(ind)
                ind = 1;
            end
            Range_num = ind(end);

            obj.Set_res_feedback(Range_num);
            
            sense = Sense_array(Range_num);
            BW = obj.bandwidth;
        end

        function [Res, BW] = Set_res_feedback(obj, Range_num)
        arguments
            obj
            Range_num double {mustBeMember(Range_num, [1, 2, 3, 4, 5, 6])}
        end
            if Range_num <= 4
                Res_array = ["RES_100", "RES_10k", "RES_1M", "RES_100M"];
                obj.FB_opamp_select("AD8065");
                obj.FB_1_select(Res_array(Range_num));
            elseif Range_num == 5
                obj.FB_opamp_select("LMC6001");
                obj.FB_2_select("10G");
            elseif Range_num == 6
                obj.FB_opamp_select("LMC6001");
                obj.FB_2_select("1T");
            end
            Res_array = [200 10e3 1e6 100e6 10e9 1e12];
            BW_array = [130e3 200e3 8.5e3 60 0.1 0.05]; % Hz
            obj.FB_res = Res_array(Range_num);
            obj.bandwidth = BW_array(Range_num);
        end

        function Set_CAP_feedback(obj, Range)
        arguments
            obj
            Range {mustBeMember(Range, ["CAP_100p", "CAP_10n", "CAP_1u", "CAP_20u"])}
        end
            obj.FB_opamp_select("AD8065");
            obj.FB_1_select(Range);
            obj.cap_short(0);
        end

        function CAP_RESET(obj)
%             obj.Current_direction("GND");
            pause(0.03)
            obj.FB_opamp_connect("disable");
            pause(0.03)
            obj.cap_short(1);
            pause(0.1)
            
            pause(0.01)
            obj.FB_opamp_connect("enable");
            pause(0.03)
            obj.cap_short(0);
%             obj.Current_direction("I2V");
        end
    end


    %------------ GET CMD public block -----------
    methods (Access = public)
        function BW = get_bandwidth(obj)
            BW = obj.bandwidth;
        end
    end


    methods (Access = protected)
        function sense = set_current_sensitivity_override(obj, Level)
            [sense, ~] = set_sensitivity(obj, Level);
        end

        function [Current, Time_data, OVLD] = get_current_value_override(obj)
            [Current, Time_data, OVLD] = obj.read_data();
            Current = -Current;
        end
    end



    methods (Access = public) % NOTE: override
        function initiate(obj)
            obj.FB_opamp_connect("enable");
            obj.Current_direction("I2V");
        end

        function terminate(obj)
            obj.FB_opamp_connect("disable");
            obj.Current_direction("GND");
            obj.FB_opamp_select("AD8065");
            obj.FB_1_select("RES_10k");
            obj.FB_2_select("10G");
            obj.cap_short(1);
        end

        function set_mode(obj, mode)
        arguments
            obj
            mode {mustBeMember(mode, ["I2V", "LCR"])}
        end
            if mode == "I2V"
                obj.init_device();
            elseif mode == "LCR"
                obj.Gen_direction("LCR");
                obj.Current_direction("LCR");
                obj.LCR_HV_direction("LCR_HC");
            end
        end
    end




    methods (Access = private)
        function send_cmd(obj, cmd, varargin)
            narginchk(2, 4);
            if nargin > 2
                arg_a = varargin{1};
            else
                arg_a = 0;
            end
            if nargin > 3
                arg_b = varargin{2};
            else
                arg_b = 0;
            end
            arg_a_bytes = flip(typecast(uint32(arg_a), 'uint8'));
            arg_b_bytes = flip(typecast(uint32(arg_b), 'uint8'));
            CMD_packet = [uint8(cmd) arg_a_bytes arg_b_bytes];
            obj.con.send(uint8(CMD_packet));
            pause(0.012);
        end
        
        function CMD_data_req(obj)
            obj.send_cmd(9);
        end


        function FB_opamp_select(obj, opamp)
            arguments
                obj
                opamp {mustBeMember(opamp, ["AD8065", "LMC6001"])}
            end
            if opamp == "AD8065"
                obj.send_cmd(10, 0);
            else
                obj.send_cmd(10, 1);
            end
        end

        function FB_opamp_connect(obj, status)
            arguments
                obj
                status {mustBeMember(status, ["enable", "disable"])}
            end
            if status == "enable"
                obj.send_cmd(11, 1);
            else
                obj.send_cmd(11, 0);
            end
        end

        function ADC_1_direction(obj, status)
            arguments
                obj
                status {mustBeMember(status, ["internal", "external"])}
            end
            if status == "internal"
                obj.send_cmd(12, 0);
            else
                obj.send_cmd(12, 1);
            end
        end

        function ADC_2_direction(obj, status)
            arguments
                obj
                status {mustBeMember(status, ["internal", "external"])}
            end
            if status == "internal"
                obj.send_cmd(13, 0);
            else
                obj.send_cmd(13, 1);
            end
        end
     
        function FB_1_select(obj, FB1)
            arguments
                obj
                FB1 {mustBeMember(FB1, ["RES_100", "RES_10k", "RES_1M", ...
                    "RES_100M", "CAP_100p", "CAP_10n", "CAP_1u", "CAP_20u"])}
            end
            switch FB1
                case "RES_100"
                    obj.send_cmd(14, 0);
                case "RES_10k"
                    obj.send_cmd(14, 1);
                case "RES_1M"
                    obj.send_cmd(14, 2);
                case "RES_100M"
                    obj.send_cmd(14, 3);
                case "CAP_100p"
                    obj.send_cmd(14, 4);
                case "CAP_10n"
                    obj.send_cmd(14, 5);
                case "CAP_1u"
                    obj.send_cmd(14, 6);
                case "CAP_20u"
                    obj.send_cmd(14, 7);
            end
        end

        function FB_2_select(obj, FB2)
            arguments
                obj
                FB2 {mustBeMember(FB2, ["10G", "1T"])}
            end
            if FB2 == "10G"
                obj.send_cmd(15, 0);
            else
                obj.send_cmd(15, 1);
            end
        end

        function Current_direction(obj, I_dir)
            arguments
                obj
                I_dir {mustBeMember(I_dir, ["GND", "I2V", "LCR", ...
                    "Redirection"])}
            end
            switch I_dir
                case "GND"
                    obj.send_cmd(16, 0);
                case "I2V"
                    obj.send_cmd(16, 1);
                case "LCR"
                    obj.send_cmd(16, 2);
                case "Redirection"
                    obj.send_cmd(16, 3);
            end
        end

        function I2V_output_direction(obj, dir)
        arguments
            obj
            dir {mustBeMember(dir, ["internal", "external"])}
        end
            if dir == "internal"
                obj.send_cmd(17, 0);
            else
                obj.send_cmd(17, 1);
            end

        end

        function LCR_HV_direction(obj, dir)
            arguments
                obj
                dir {mustBeMember(dir, ["LCR_HC", "V1_input"])}
            end
            if dir == "LCR_HC"
                obj.send_cmd(18, 0);
            else
                obj.send_cmd(18, 1);
            end

        end

        function Self_calibration_select(obj, self_cal)
            arguments
                obj
                self_cal {mustBeMember(self_cal, ["none", "CAP_200p", ...
                    "RES_10M", "BOTH"])}
            end
            switch self_cal
                case "none"
                    obj.send_cmd(19, 0);
                case "CAP_200p"
                    obj.send_cmd(19, 1);
                case "RES_10M"
                    obj.send_cmd(19, 2);
                case "BOTH"
                    obj.send_cmd(19, 3);
            end
        end

        function Gen_direction(obj, gen_dir)
            arguments
                obj
                gen_dir {mustBeMember(gen_dir, ["Internal", "Lock_in", ...
                    "LCR", "External"])}
            end
            switch gen_dir
                case "Internal"
                    obj.send_cmd(20, 0);
                case "Lock_in"
                    obj.send_cmd(20, 1);
                case "LCR"
                    obj.send_cmd(20, 2);
                case "External"
                    obj.send_cmd(20, 3);
            end
        end
        
        function cap_short(obj, state)
            if state ~= 0 && state ~= 1
                error(['Wrong argument: ' char(state)]);
            end
            obj.send_cmd(3, state);
        end
        


        
        function init_device(obj)
            obj.FB_opamp_select("AD8065");
            obj.FB_opamp_connect("disable");
            obj.ADC_1_direction("external");
            obj.ADC_2_direction("internal");
            obj.FB_1_select("RES_10k");
            obj.FB_2_select("10G");
            obj.Current_direction("GND");
            obj.I2V_output_direction("internal");
            obj.LCR_HV_direction("LCR_HC");
            obj.Self_calibration_select("none");
            obj.Gen_direction("Lock_in");
            obj.cap_short(1);

            obj.FB_res = 10e3;
            obj.bandwidth = 200e3;
        end


        function [Current, Time_data, OVLD] = read_data(obj)
            obj.CMD_data_req();
            pause(0.01);
            [Time, ~, Voltage2, ~, ~, ~] = high_level_read(obj);
            Time_data = Time;
            if abs(Voltage2) > 5
                OVLD = true;
            else
                OVLD  = false;
            end
            Current = Voltage2/obj.FB_res;
        end

        function [Full_time_stamp, ADC_1_voltage, ADC_2_voltage, ...
                Relay_state_byte, Device_state_byte] = debug_read(obj)

            number_of_bytes = 16;
            Data = obj.con.read();
            table = reshape(Data, [number_of_bytes numel(Data)/number_of_bytes]);
            if ~isempty(table)
                [Data_table, CMD_table] = split_tables(table);
                [Device_state_byte, Relay_state_byte, Full_time_stamp, ...
                ADC_1_voltage, ADC_2_voltage] = parse_data_table(Data_table);
            else
                error('no data avilable') %FIXME: add error handler
            end
        end

        function [Time, Voltage1, Voltage2, Unit, Relay_state, ...
                Device_state_byte] = high_level_read(obj)
            try
                [Full_time_stamp, ADC_1_voltage, ADC_2_voltage, ...
                    Relay_state_byte, Device_state_byte] = obj.debug_read;
                % FIXME: add filtering
%                 [Relay_state, Unit, multiplier] = relay_byte_parse(Relay_state_byte);
                Relay_state = -1;
                Unit = -1;
                multiplier = -1;
                Time = double(Full_time_stamp)*100e-6; % s
                Voltage1 = ADC_2_voltage; % V
                Voltage2 = ADC_1_voltage;
%                 Device_state_byte = Device_state_byte;
            catch e
                rethrow(e);
            end
        end

    end

end












function [Data_table, CMD_table] = split_tables(table)
Data_table = table;
CMD_rows = 1; % FIXME: magic constant
CMD_value_data = 170; % FIXME: magic constant

CMD = Data_table(CMD_rows, :);

range = CMD ~= CMD_value_data;
CMD_table = Data_table(:,range);
Data_table(:,range) = [];
Data_table(1,:) = [];

end

function [Device_state, Relay_state_byte, Full_time_stamp, ...
    ADC_1_voltage, ADC_2_voltage] = parse_data_table(Data_table)

Device_state_rows = 2 - 1; % FIXME: magic constant
Relay_state_rows = 3 - 1; % FIXME: magic constant
TS_epoch_rows = 4 - 1; % FIXME: magic constant
TS_time_rows = (5:8) - 1; % FIXME: magic constant
ADC1_argA_row = (9:12) - 1; % FIXME: magic constant
ADC2_argB_row = (13:16) - 1;  % FIXME: magic constant
ADC1_ref_voltage = 4.096*3; % FIXME: magic constant
ADC2_ref_voltage = 4.096*3; % FIXME: magic constant

%
Device_state = Data_table(Device_state_rows, :);
Relay_state_byte = Data_table(Relay_state_rows, :);

%
Time_stamp_epoch_part = Data_table(TS_epoch_rows, :);
Time_stamp_epoch = uint64(typecast(uint8(Time_stamp_epoch_part), 'uint8'));

Time_stamp_time_part = Data_table(TS_time_rows, :);
Time_stamp_time_part = reshape(Time_stamp_time_part, [1 numel(Time_stamp_time_part)]);
Time_stamp_time = uint64(typecast(uint8(Time_stamp_time_part), 'uint32'));

Full_time_stamp = Time_stamp_epoch*uint64(2^32) + Time_stamp_time;

%
ADC1_part = Data_table(ADC1_argA_row, :);
ADC1_part = reshape(ADC1_part, [1 numel(ADC1_part)]);
ADC_1_code = double(typecast(uint8(ADC1_part), 'int32'));
ADC_1_voltage = ADC_1_code/2^17*ADC1_ref_voltage;
% ADC_1_voltage = ADC_1_code;

ADC2_part = Data_table(ADC2_argB_row, :);
ADC2_part = reshape(ADC2_part, [1 numel(ADC1_part)]);
ADC_2_code = double(typecast(uint8(ADC2_part), 'int32'));
ADC_2_voltage = ADC_2_code/2^17*ADC2_ref_voltage;
% ADC_2_voltage = ADC_2_code;

end





