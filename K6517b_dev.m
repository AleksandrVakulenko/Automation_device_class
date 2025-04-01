% Date: 2025.04.01
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
%  4) 
%  5) find useful CMDs

% set_zero_check
% enable_feedback
classdef K6517b_dev < aDevice
    methods (Access = public)
        function obj = K6517b_dev(GPIB_num)
            arguments
                % FIXME: maybe list of values? (mustbemember)
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

        function enable_feedback(obj, state)
        arguments
            obj
            state (1,1) string {mustBeMember(state, ["enable", "disable"])}
        end
            if state == "enable"
                CMD = ":SYSTem:ZCHeck OFF";
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


end






