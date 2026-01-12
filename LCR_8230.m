% Date: 2025.08.12
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: GW INSTEK
% Model: LCR-8230
% Description: LCR Meter
% 
% ------------

% TODO:
% 1)

classdef LCR_8230 < aDevice

    methods (Access = public)
        function obj = LCR_8230(GPIB_num)
            arguments
                GPIB_num {adev_utils.GPIB_validation(GPIB_num), ...
                    mustBeMember(GPIB_num, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, ...
                    25, 26, 27, 28, 29, 30])}
            end
            obj@aDevice(Connector_GPIB(GPIB_num))
        end
    end

    methods (Access = public) % NOTE: override (not now)
        function initiate(obj)
            obj.set_out_param;
            obj.set_amplitude(0.01);
            obj.set_freq(30e6);
        end

        function terminate(obj)
            obj.set_amplitude(0.01);
            obj.set_freq(30e6);
        end
    end

    %---------- DEBUG CMD public block ----------
    methods (Access = public)
        function resp = READ(obj)
            resp = obj.con.read();
        end

        function resp = QUERY(obj, CMD)
            resp = obj.query_and_log(CMD);
        end

        function SEND(obj, CMD)
            obj.con.send(CMD);
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

    %---------- SET CMD public block ----------
    methods (Access = public)
        function set_amplitude(obj, amp)
            arguments
                obj
                amp {mustBeInRange(amp, -1, 1)}
            end
            CMD = sprintf(":MEASure:VOLTage:AC %.3e", amp);
            obj.send_and_log(CMD);
        end

        function set_freq(obj, freq)
            arguments
                obj
                freq {mustBeInRange(freq, 10, 30e6)}
            end
            CMD = sprintf(":MEASure:FREQuency %.6e", freq);
            obj.send_and_log(CMD);
        end

        function set_out_param(obj)
            arguments
                obj
            end
            % NOTE: hardcoded to DC Resistance, Impedance, Angle(deg)
            % could be called from initiate()
            CMD = ":MEASure:PARAmeter RDC,Z,DEG,OFF";
            obj.send_and_log(CMD);
        end

        function set_measure_speed(obj, speed)
            arguments
                obj
                speed {mustBeMember(speed, ["slow", "medium", "fast"])}
            end
            CMD = [':MEASure:SPEEd ' char(speed)];
            obj.send_and_log(CMD);
        end

    end
%     :MEASure:SPEEd

    %---------- GET CMD public block ----------
    methods (Access = public)
        function [volt_ac, cur_ac] = get_v_i_ac(obj)
            resp = obj.query_and_log(":FETCH:SMONitor:AC?");
            try
                data = sscanf(resp, "%f, %f");
                volt_ac = data(1);
                cur_ac = data(2);
            catch
                volt_ac = NaN;
                cur_ac = NaN;
                DEBUG_MSG("error in FETCH AC V and I", "red");
            end
        end

        function [RDC, Z, DEG, resp] = measure_and_read(obj)
            resp = obj.query_and_log("*TRG?");
            try
                [data, num] = sscanf(resp, "%f, %f, %f, %f");
            catch
                data = [];
                num = 0;
            end

            if num >= 3
                RDC = data(1);
                Z = data(2);
                DEG = data(3);
            else
                RDC = NaN;
                Z = NaN;
                DEG = NaN;
                DEBUG_MSG("error in MEASURE_AND_READ", "red");
            end

        end

    end


end