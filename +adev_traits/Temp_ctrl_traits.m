% Date: 2026.11.25
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Traits class: common interface for temperature controllers>
% Type: abstract, not a standalone device class
% 
% Description: Public wrappers (setpoint, ramp target/rate, actual
% temperature, heater active state) with K/C unit conversion and input
% validation. Hardware-specific part is implemented via protected
% abstract *_override methods.
% 
% Usage: classdef My_controller < aDevice & adev_traits.Temp_ctrl_traits
%   and implement all *_override methods, otherwise class stays abstract.
%
% ------------

% TODO:
% 1) Consider initiate/terminate for consistency with other traits
% 2) Clarify set_active semantics (+ paired get_active?)



classdef Temp_ctrl_traits < handle

    properties

    end

    methods (Access = public)
        function set_setpoint(obj, setpoint, unit)
            arguments
                obj adev_traits.Temp_ctrl_traits
                setpoint (1,1) double
                unit {mustBeMember(unit, ["K", "C"])} = "K"
            end
            setpoint_kelvin = temp_unit_conv(setpoint, unit);
            abs_temp_check(setpoint_kelvin);
            obj.set_setpoint_override(setpoint_kelvin);
        end

        function set_ramp_target(obj, ramp_target, unit)
            arguments
                obj adev_traits.Temp_ctrl_traits
                ramp_target (1,1) double
                unit {mustBeMember(unit, ["K", "C"])} = "K"
            end
            ramp_target_kelvin = temp_unit_conv(ramp_target, unit);
            abs_temp_check(ramp_target_kelvin);
            obj.set_ramp_target_override(ramp_target_kelvin);
        end

        function set_ramp_rate(obj, ramp_rate, unit)
            arguments
                obj adev_traits.Temp_ctrl_traits
                ramp_rate (1,1) double
                unit {mustBeMember(unit, ["K/min"])} = "K/min"
            end
            % FIXME: unit unused
            if ramp_rate <= 0
                error("Ramp rate must be greater than zero")
            end
            obj.set_ramp_rate_override(ramp_rate);
        end

        function setpoint = get_setpoint(obj, unit)
            arguments
                obj adev_traits.Temp_ctrl_traits
                unit {mustBeMember(unit, ["K", "C"])} = "K"
            end
            setpoint_kelvin = obj.get_setpoint_kelvin_override();
            setpoint = temp_unit_conv(setpoint_kelvin, unit);
        end

        function ramp_target = get_ramp_target(obj, unit)
            arguments
                obj adev_traits.Temp_ctrl_traits
                unit {mustBeMember(unit, ["K", "C"])} = "K"
            end
            ramp_target_kelvin = obj.get_ramp_target_kelvin_override();
            ramp_target = temp_unit_conv(ramp_target_kelvin, unit);
        end

        function ramp_rate = get_ramp_rate(obj)
            arguments
                obj adev_traits.Temp_ctrl_traits
            end
            ramp_rate = obj.get_ramp_rate_override();
        end

        function temp_array = get_actual_temp(obj)
            arguments
                obj adev_traits.Temp_ctrl_traits
            end
            temp_array = obj.get_actual_temp_override();
        end

        function set_active(obj, status)
            arguments
                obj adev_traits.Temp_ctrl_traits
                status (1,1) logical
            end
            obj.set_active_override(status);
        end

    end

    methods (Access = protected, Abstract)
        set_setpoint_override(obj, setpoint_kelvin);
        set_ramp_target_override(obj, ramp_target_kelvin);
        set_ramp_rate_override(obj, ramp_rate);

        setpoint = get_setpoint_kelvin_override(obj);
        ramp_target = get_ramp_target_kelvin_override(obj);
        ramp_rate = get_ramp_rate_override(obj);

        temp_array = get_actual_temp_override(obj);

        set_active_override(obj, status);
    end

end



function abs_temp_check(temp)
arguments
    temp (1,1) double
end
    if temp < 0
        error(['Absolute temperature could not be less than zero:' ...
            newline 'received: ' num2str(temp, '%0.3e') ' K'])
    end
end


function temp_K = temp_unit_conv(temp, unit)
arguments
    temp (1,1) double
    unit {mustBeMember(unit, ["K", "C"])} = "K"
end
    if isnan(temp)
        error('Temp value could not be NaN');
    end
    if unit == "C"
        temp_K = temp + 273.15;
    else
        temp_K = temp;
    end
end
