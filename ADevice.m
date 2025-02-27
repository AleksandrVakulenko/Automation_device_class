% Date: 2025.02.27
% Version: 0.0
% Author: Aleksandr Vakulenko
%
% ----INFO----:
% ADevice (handle) is an abstract class  for wraping any automation
% and measurement devices.
% 
% Real devices is maintaned by inherited subclasses.
% 
% 1) Any subclass builds itself by obj@ADevice constructor.
% 
% 

classdef ADevice < handle
    methods (Access = public)
        function obj = ADevice(connector)
            arguments
                connector Connector = Connector_empty;
            end
            obj.con = connector;
            disp("ADevice C-tor") % FIXME: debug
        end

        function delete(obj)
            disp("ADevice D-tor") % FIXME: debug
        end
    end
    
    

    properties (Access = protected)
        con Connector = Connector_empty;
    end
end










