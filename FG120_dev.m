

classdef FG120_dev < aDevice

    methods (Access = public)
        function obj = FG120_dev(GPIB_num)
            arguments
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB(GPIB_num))
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


    end

end







