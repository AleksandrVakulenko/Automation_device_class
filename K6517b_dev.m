% Date: 2025.04.03
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Keithley
% Model: 6517b
% Description: Electrometer
%
% ------------

% TODO:
%  1) Add charge sense mode
%  2) Add prop of current mode
%  3) Make sense func whitout mode
%  4) find useful CMDs: speed, digits, ...
%  5) find values of Feedback elements
%  6) rename enable_feedback()

classdef K6517b_dev < aDevice & I2V_converter_traits
    methods (Access = public)
        function obj = K6517b_dev(GPIB_num)
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
    end


    %--------- DATA READ CMD public block --------
    methods (Access = public)
        function resp = read_last(obj)
            CMD = ":FETCh?";
            resp = obj.query_and_log(CMD);
        end
    end


    %------------ SET CMD public block -----------
    methods (Access = public)
        function config(obj, mode)
            arguments
                obj
                mode {mustBeMember(mode, ["volt", "current", "charge"])}
            end
            switch mode
                case "volt"
                    CMD = ":SENSe:FUNCtion ""voltage""";
                case "current"
                    CMD = ":SENSe:FUNCtion ""current""";
                case "charge"
                    CMD = ":SENSe:FUNCtion ""charge""";
                otherwise
                    error('placeholder') % FIXME
            end
            obj.send_and_log(CMD);
        end

        function enable_feedback(obj, state, speed)
            arguments
                obj
                state (1,1) string {mustBeMember(state, ["enable", "disable"])}
                speed {mustBeMember(speed, ["fast", "normal"])} = "normal"
            end
            if state == "enable"
                CMD = ":SYSTem:ZCHeck OFF";
                if speed == "normal"
                    % NOTE: wait for input relax time
                    adev_utils.Wait(3, 'activate Electrometer input'); % FIXME: magic constant
                end
            else
                CMD = ":SYSTem:ZCHeck ON";
            end
            obj.send_and_log(CMD);
        end

        function sens = set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, ["voltage", "current"])} = "current";
            end

            if mode == "voltage"
                func = "VOLTage";
            else
                func = "CURRent";
            end

            CMD = sprintf(":SENSe:%s:RANGe %d", func, Level);
            obj.send_and_log(CMD);


            CMD = sprintf(":SENSe:%s:RANGe?", func);
            resp = obj.query_and_log(CMD);
            sens = str2double(resp);
        end
    end


    %------------ GET CMD public block -----------
    methods (Access = public)


    end

    methods (Access = protected)
        % FIXME: add to TEST
        function sense = set_current_sensitivity_override(obj, Level)
            sense = obj.set_sensitivity(Level, "current");
        end

        function [Current, Time_data, OVLD] = get_current_value_override(obj)
            warning('function is not ready to use!')
            Current = NaN;
            Time_data = 0;
            OVLD = false;
        end

        function start_of_measurement(obj)
            obj.config("current");
            obj.enable_feedback("enable");
            pause(0.5);
        end
        
        function end_of_measurement(obj)
            obj.enable_feedback("disable");
        end
    end


end






