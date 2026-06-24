
% TODO:
% Ammeter props:
% 1) Range list
% 2) 
% 3) 
% 4) 
% 5) 
% 6) 
% 7) 
% 

% Range props
% 1) Sense
% 2) BW
% 3) 
% 4) 

% FIXME: maybe put "initiate" and "terminate" to aDevice?

classdef I2V_converter_traits < handle
    
    methods (Access = public)
        function sense = set_current_sensitivity(obj, Level)
            arguments
                obj I2V_converter_traits
                Level (1,1) double
            end
            sense = obj.set_current_sensitivity_override(Level);
        end

        function [Current, Time_data, OVLD] = get_current_value(obj)
            arguments
                obj I2V_converter_traits
            end
            [Current, Time_data, OVLD] = obj.get_current_value_override();
        end
    
        
    end
    
    methods (Access = protected, Abstract)
        sense = set_current_sensitivity_override(obj, Level)
        [Current, Time_data, OVLD] = get_current_value_override(obj)
    end

    methods (Access = public, Abstract)
        initiate(obj)
        terminate(obj)
    end

end











