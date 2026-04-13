
% TODO:
% 1) Maybe delete this ???
% 2) Maybe delete this ???
% 3) Maybe delete this ???
% 4) Maybe delete this ???
% 5) Maybe delete this ???




classdef Connector_board_traits < handle
    
    methods (Access = public)
        function set_connection_mode(obj, mode)
            arguments
                obj Connector_board_traits
                mode {mustBeMember(mode, ["I2V", "LCR", "Bypass"])}
            end
            obj.set_mode_override(mode);
        end

        
    end
    
    methods (Access = protected, Abstract)
        set_mode_override(obj, mode)
    end

end