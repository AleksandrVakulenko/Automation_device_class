% Date: 2025.04.016
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Femto
% Model: DLPCA-200
% Description: Current to voltage converter
%
% The digital interface is implemented on ATmega328P
% https://disk.yandex.ru/d/ZrsTtyNYrqvmog
% ------------

% TODO:
%  1) Change Vref to external (from 5V input of DLPCA)
%  2) Create Ammeter_traits
%  3)

classdef DLPCA200_dev < aDevice
    properties (Access = private)
        sense
        bandwidth
    end

    methods (Access = public)
        function obj = DLPCA200_dev(COM_port_N)
            arguments
                COM_port_N {mustBeNumeric(COM_port_N)}
            end
            COM_port_name = string(['COM' num2str(COM_port_N)]);
            obj@aDevice(Connector_COM_RS232(COM_port_name, 115200));
            obj.set_sensitivity(3, "L");
        end

        function resp = get_IDN(obj)
            warning("*IDN? cmd is not supported");
            resp = "*IDN? cmd is not supported";
        end
    end


    %--------- DATA READ CMD public block --------
    methods (Access = public)
        function [Current, Time_data, OVLD] = read_data(obj)
            [ADC_data, Time_data, OVLD, ~] = read_last(obj);
            ADC_data = ADC_data/1024*5; % V
            Voltage = (ADC_data - 2.5) * 5; % V
            Current = obj.sense * Voltage;
        end
    end


    %------------ SET CMD public block -----------
    methods (Access = public)
        function [sense, BW] = set_sensitivity(obj, Level, Range)
            arguments
                obj
                Level (1,1) double {mustBeMember(Level, ...
                    [3, 4, 5, 6, 7, 8, 9, 10, 11])}
                Range {mustBeMember(Range, ["H", "L"])} = "L"
            end
            if Level < 4
                Range = "L";
            end
            if Level > 9
                Range = "H";
            end
            if Range == "H" % convert to array number (1 to 7)
                Level = Level - 2 - 2;
            else
                Level = Level - 2;
            end
            BW_array = [500 500 400 200 50 7 1] * 1e3; % Hz
            obj.bandwidth = BW_array(Level);
            obj.set_rangeHLandNum(Level, Range);
            if Range == "H"
                Sens_array = [-5, -6, -7, -8, -9, -10, -11];
            else
                Sens_array = [-3, -4, -5, -6, -7, -8, -9];
            end
            obj.sense = 10^Sens_array(Level);
            sense = obj.sense;
            BW = obj.bandwidth;
        end
    end


    %------------ GET CMD public block -----------
    methods (Access = public)
        function BW = get_bandwidth(obj)
            BW = obj.bandwidth;
        end
    end


    methods (Access = private)
        function set_rangeHL(obj, Range)
            arguments
                obj
                Range {mustBeMember(Range, ["H", "L"])}
            end
            % FIXME: undone
            error('empty function')
        end

        function set_rangeNum(obj, Level)
            arguments
                obj
                Level (1,1) double {mustBeMember(Level, ...
                    [1, 2, 3, 4, 5, 6, 7])}
            end
            % FIXME: undone
            error('empty function')
        end

        function [ADC_data, Time_data, OVLD, serv1] = read_last(obj)
            CMD = uint8([1 0 0 0 0]);
            resp = obj.con.query(CMD, "norm");
            if isempty(resp)
                pause(0.1);
                resp = obj.con.query(CMD, "norm");
                if isempty(resp)
                    error("Device is not responding");
                end
            end
            data_array = uint8(resp);
            serv1 = data_array(1);
            OVLD = data_array(2);
            ADC_data = double(data_array(4))*256 + double(data_array(3));
            Time_data = uint8((data_array(5:8)));
            Time_data = typecast(Time_data, 'uint32');
            Time_data = double(Time_data)/1000;
        end

        function set_rangeHLandNum(obj, Level, Range)
            arguments
                obj
                Level (1,1) double {mustBeMember(Level, ...
                    [1, 2, 3, 4, 5, 6, 7])}
                Range {mustBeMember(Range, ["H", "L"])}
            end
            % PORT D
            % bit 0 : RX
            % bit 1 : TX
            % bit 2 : range LSB
            % bit 3 : range
            % bit 4 : range MSB
            % bit 5 : AC(low) / DC(high)
            % bit 6 : Low noise(high) / High_speed(low)
            % bit 7 : null
            ctrl_value = Level - 1; % convert to array number (0 to 6)
            ctrl_value = ctrl_value + 8; % DC mode always ON
            if Range == "L"
                ctrl_value = ctrl_value + 16; % set bin #4
            end
            ctrl_value = ctrl_value * 4; % shift left by 2
            CMD = uint8([3 0 ctrl_value 0 0]);
            obj.con.send(CMD);
        end
    end

end






