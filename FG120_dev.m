% Date: 2025.04.02
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Yokogawa
% Model: FG120
% Description: Function generator
% 
% ------------

classdef FG120_dev < aDevice

    methods (Access = public)
        function obj = FG120_dev(GPIB_num)
            arguments
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB_fast(GPIB_num))
            DEBUG_MSG("FG120 generator", 'red', 'ctor')
        end
    end

    %----------- CMD block -----------
    methods (Access = public)

        function set_freq(obj, freq_Hz)
            arguments
                obj
                freq_Hz {mustBeNumeric(freq_Hz), ...
                    mustBeGreaterThanOrEqual(freq_Hz, 1e-6), ...
                    mustBeLessThanOrEqual(freq_Hz, 2e6)}
            end
            CMD = num2str(freq_Hz, "freq %.8f");
            obj.con.send(CMD);
        end

        function [freq, unit] = get_freq(obj)
            CMD = ['freq?'];
            freq_text = obj.con.query(CMD);
            freq = sscanf(freq_text, "FREQ %fHz");
            unit = "Hz";
        end

        function bad_foo(obj)
            CMD = ['freqz?'];
            freq_text = obj.con.query(CMD);
            freq_text
            freq = sscanf(freq_text, "FREQ %fHz");
            unit = "Hz";
        end

    end

end







