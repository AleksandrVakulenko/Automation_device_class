
classdef Astra_pulse_waveform_init

    methods (Access = public)
        function obj = Astra_pulse_waveform_init(amp, period, bias, duty_cycle, ...
                pulse_type, gen_type, continuous)

        arguments
            amp double
            period double
            bias double
            duty_cycle double
            pulse_type {mustBeMember(pulse_type, ["bipolar", ...
                "inverse_bipolar", "positive", "negative"])}
            gen_type {mustBeMember(gen_type, ["triangle", "sin", ...
                "noise", "pulse"])}
            continuous logical
        end

            if amp < 0
                amp = -amp;
            end
            if amp > 10
                amp = 10;
            end

            Max_bias = 10-amp;
            
            if abs(bias) > Max_bias
                bias = sign(bias)*Max_bias;
            end

            % FIXME: delete this
%             disp('---------------------------')
%             disp('---------------------------')
%             disp('---------------------------')
%             disp(bias)
%             disp('---------------------------')
%             disp('---------------------------')
%             disp('---------------------------')
%             pause(0.5)

            switch pulse_type
                case {"bipolar", "b"}
                    obj.pulse_type = 1;
                case {"inverse_bipolar", "ib", "bi"}
                    obj.pulse_type = 2;
                case {"pos", "positive", "p"}
                    obj.pulse_type = 3;
                case {"neg", "negative", "n"}
                    obj.pulse_type = 4;
                otherwise
                    error(['Wrong pulse type: "' char(pulse_type) '"'])
            end

            switch gen_type
                case {"triangle", "tri"}
                    obj.gen_type = 1;
                case {"sin", "sine"}
                    obj.gen_type = 2;
                case {"noise"}
                    obj.gen_type = 3;
                case {"pulse", "square", "sq"}
                    obj.gen_type = 4;
                otherwise
                    error(['Wrong gen type: "' char(gen_type) '"'])
            end
            obj.amplitude = amp;
            obj.period = period;
            obj.DC_bias = bias;
            obj.duty_cycle = duty_cycle/100;
            obj.continuous = continuous;
        end

        function [prop_float, prop_uint8] = get_prop(obj)
            prop_float = single([obj.amplitude, obj.period, obj.DC_bias obj.duty_cycle]);
            prop_uint8 = uint8([obj.pulse_type, obj.gen_type, obj.continuous]);
        end
    end

    properties (Access = private)
        amplitude double = 0;
        period double = 0;
        DC_bias double = 0;
        duty_cycle double = 0;
        pulse_type uint8 = 0;
        gen_type uint8 = 0;
        continuous logical = 0;
    end
end





