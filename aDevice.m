% Date: 2025.03.04
% Version: 1.0
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% aDevice (handle) is an abstract class for wraping any automation
% and measurement device.
% 
% Real devices are maintaned by inherited subclasses.
% 
% 1) Any subclass builds itself by obj@aDevice constructor with
% any type of connector.
% ------------

% TODO:
% 1) add log control
% 2) add log to file


classdef aDevice < handle
    methods (Access = public)
        function obj = aDevice(connector)
            arguments
                connector Connector;
            end
            obj.con = connector;
        end
    end
    
    methods (Access = protected)
        function DEBUG_CMD_LOG(obj, CMD)
            DEV = string(class(obj));
            MSG = "CMD > " + DEV + ": " + CMD;
            DEBUG_MSG(MSG, "orange");
        end
    end
    
    properties (Access = protected)
        con Connector = Connector_empty;
    end
end










