

classdef LCR_meter_traits < handle

    methods (Access = public)
        function Freq_out = set_freq(obj, Freq)
            arguments
                obj adev_traits.LCR_meter_traits
                Freq (1,1) double {mustBeGreaterThan(Freq, 0)}
            end
            Freq_out = obj.set_freq_override(Freq);
        end

        function Amp_out = set_amplitude(obj, Amp)
            arguments
                obj adev_traits.LCR_meter_traits
                Amp (1,1) double {mustBeGreaterThan(Amp, 0)}
            end
            Amp_out = obj.set_amplitude_override(Amp);
        end

        function DC_bias_out = set_DC_bias(obj, DC_bias)
            arguments
                obj adev_traits.LCR_meter_traits
                DC_bias (1,1) double
            end
            DC_bias_out = obj.set_DC_bias_override(DC_bias);
        end

        function set_accuracy_level(obj, Time_profile)
            arguments
                obj adev_traits.LCR_meter_traits
                Time_profile string {mustBeMember(Time_profile, ...
                    ["ultra_fast", "common", "fine", "most_accurate"])} = "common"
            end
            switch Time_profile
                case "ultra_fast"
                    Accuracy_level = 1;
                case "common"
                    Accuracy_level = 2;
                case "fine"
                    Accuracy_level = 3;
                case "most_accurate"
                    Accuracy_level = 4;
            end
            obj.set_accuracy_override(Accuracy_level);
        end
    
        function Accuracy_level = get_accuracy_level(obj)
            arguments
                obj adev_traits.LCR_meter_traits
            end
            Accuracy_level = obj.get_accuracy_level_oveeride();
        end
    
        function [R_abs, Phi_deg] = get_R_Phi(obj)
            arguments
                obj adev_traits.LCR_meter_traits
            end
            [R_abs, Phi_deg] = obj.get_R_Phi_override();
        end

        function [R_abs, Phi_deg, R_abs_err, Phi_deg_err] = ...
                get_R_Phi_with_errors(obj, Time_profile)
            arguments
                obj adev_traits.LCR_meter_traits
                Time_profile string {mustBeMember(Time_profile, ...
                    ["ultra_fast", "common", "fine", "most_accurate", ""])} = ""
            end
            if Time_profile ~= ""
                obj.set_accuracy_level(Time_profile);
            end
            Accuracy_level = obj.get_accuracy_level();
            % FIXME: need tests
            switch Accuracy_level
                case 1
                    N = 3;
                case 2
                    N = 5;
                case 3
                    N = 7;
                case 4
                    N = 15;
                otherwise
                    N = 3;
            end
            R_abs_arr = NaN(1, N);
            Phi_deg_arr = NaN(1, N);
            for i = 1:N
                [R_abs, Phi_deg] = obj.get_R_Phi_override();
                R_abs_arr(i) = R_abs;
                Phi_deg_arr(i) = Phi_deg;
            end
            R_abs = mean(R_abs_arr);
            R_abs_err = 3*std(R_abs_arr);
            Phi_deg = mean(Phi_deg_arr);
            Phi_deg_err = 3*std(Phi_deg_arr);
        end

        function Limits = get_max_amp_and_freq(obj)
            arguments
                obj adev_traits.LCR_meter_traits
            end
            [Min_amp, Max_amp, Min_freq, Max_freq] = obj.get_max_amp_and_freq_override();
            Limits.amp_min = Min_amp;
            Limits.amp_max = Max_amp;
            Limits.freq_min = Min_freq;
            Limits.freq_max = Max_freq;
        end
    end
    
    methods (Access = protected, Abstract)
        Freq_out = set_freq_override(obj, Freq);
        Amp_out = set_amplitude_override(obj, Amp);
        DC_bias_out = set_DC_bias_override(obj, DC_bias);
        set_accuracy_override(obj, Accuracy_level);
        Accuracy_level = get_accuracy_level_oveeride(obj);
        [R_abs, Phi_deg] = get_R_Phi_override(obj);
        [Min_amp, Max_amp, Min_freq, Max_freq] = get_max_amp_and_freq_override(obj);
    end

    methods (Access = public, Abstract)
        initiate(obj)
        terminate(obj)
    end

end











