
% TODO:
% 1) 
% 2) 
% 3) 
% 4) 
% 5) 
% 6) 
% 7) 
% 



classdef Connector_board_traits < handle
    
    methods (Access = public)
        function set_connection_mode(obj, mode)
            arguments
                obj Connector_board_traits
                mode {mustBeMember(mode, ["I2V", "LCR"])}
            end
            obj.set_mode_override(mode);
        end

        
    end
    
    methods (Access = protected, Abstract)
        set_mode_override(obj, mode)
    end

end