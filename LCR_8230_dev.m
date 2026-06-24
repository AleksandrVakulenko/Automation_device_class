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
% 1) add more functions

classdef LCR_8230_dev < aDevice & adev_traits.LCR_meter_traits
    properties(Access = private)
        Accuracy_level = [];
    end

    methods (Access = public)
        function obj = LCR_8230_dev(GPIB_num)
            arguments
                GPIB_num {con_utils.GPIB_validation(GPIB_num), ...
                    mustBeMember(GPIB_num, [1, 2, 3, 4, 5, 6, 7, 8, 9, 10, ...
                    11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, ...
                    25, 26, 27, 28, 29, 30])}
            end
            % FIXME: replace by Connector_VISA 
            obj@aDevice(Connector_GPIB(GPIB_num))
            obj.Accuracy_level = 1;
            obj.set_measure_speed("fast"); % FIXME: replace
            obj.terminate();
        end
    end


    methods (Access = public) % NOTE: override (not now)
        function initiate(obj)
            obj.set_out_param_to_Z_DEG();
            obj.set_amplitude(0.01); % FIXME: is it min amp?
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
                amp {mustBeInRange(amp, 0, 1)} % FIXME: is max amp == 1?
            end
            CMD = sprintf(":MEASure:VOLTage:AC %.3e", amp);
            % FIXME: read back
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
            % FIXME: hardcoded to DC Resistance, Impedance, Angle(deg)
            % could be called from initiate()
            CMD = ":MEASure:PARAmeter RDC,Z,DEG,OFF";
            obj.send_and_log(CMD);
        end

        function set_out_param_to_Z_DEG(obj)
            arguments
                obj
            end
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
            % NOTE: legacy function
            obj.query_and_log('*TRG');
            resp = obj.query_and_log(':FETCh?');
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

        function [RDC, Z, DEG, resp] = measure_and_read_Z_DEG(obj)
            obj.set_out_param_to_Z_DEG() % NOTE: every time
            obj.query_and_log('*TRG');
            resp = obj.query_and_log(':FETCh?');
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


    methods (Access = protected)
        function Freq_out = set_freq_override(obj, Freq)
            arguments 
                obj LCR_8230_dev
                Freq double
            end
            obj.set_freq(Freq);
            Freq_out = Freq; % FIXME: debug mode
        end

        function Amp_out = set_amplitude_override(obj, Amp)
            arguments
                obj LCR_8230_dev
                Amp double
            end
            obj.set_amplitude(Amp);
            Amp_out = Amp; % FIXME: debug mode until fix 
        end

        function DC_bias_out = set_DC_bias_override(obj, DC_bias)
            arguments
                obj LCR_8230_dev
                DC_bias double
            end
            DC_bias_out = 0; % FIXME: debug mode
        end

        function set_accuracy_override(obj, Accuracy_level)
            arguments
                obj LCR_8230_dev
                Accuracy_level {mustBeMember(Accuracy_level, [1, 2, 3, 4])}
            end
            obj.Accuracy_level = Accuracy_level;
            switch Accuracy_level
                case 1
                    obj.set_measure_speed("fast")
                case 2
                    obj.set_measure_speed("medium")
                case 3
                    obj.set_measure_speed("slow")
                case 4
                    obj.set_measure_speed("slow")
            end
        end

        function Accuracy_level = get_accuracy_level_oveeride(obj)
            arguments
                obj LCR_8230_dev
            end
            Accuracy_level = obj.Accuracy_level;
        end

        function [R_abs, Phi_deg] = get_R_Phi_override(obj)
            arguments
                obj LCR_8230_dev
            end
            [~, R_abs, Phi_deg] = obj.measure_and_read_Z_DEG();
        end

        function [Max_amp, Max_freq] = get_max_amp_and_freq_override(obj)
            arguments
                obj LCR_8230_dev
            end
            Max_amp = 1; % FIMXE: maybe wrong
            Max_freq = 30e6;
        end
        
    end


end