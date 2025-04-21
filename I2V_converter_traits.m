


classdef I2V_converter_traits
    
    methods (Access = public)
        function sense = set_current_sensitivity(obj, Level)
            arguments
                obj I2V_converter_traits
                Level (1,1) double
            end
            sense = obj.set_I2V_sensitivity(Level);
        end

        function [Current, Time_data, OVLD] = get_current_value(obj)
            arguments
                obj I2V_converter_traits
            end
            [Current, Time_data, OVLD] = obj.get_I_value();
        end
    end
    
    methods (Access = protected, Abstract)
        sense = set_current_sensitivity_override(obj, Level)
        [Current, Time_data, OVLD] = get_current_value_override(obj)
    end

end











