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
% 3) connection verification
% 4) instrument find


classdef aDevice < handle
    properties (Access = protected)
        con Connector = Connector_empty;
    end

    methods (Access = public)
        function obj = aDevice(connector)
            arguments
                connector Connector;
            end
            obj.con = connector;
        end
    end

    methods (Access = private)
        function DEBUG_CMD_LOG(obj, CMD)
            DEV = string(class(obj));
            MSG = "CMD from <" + DEV + ">: """ + CMD + """";
            DEBUG_MSG(MSG, "orange");
        end
        function DEBUG_RESP_LOG(obj, RESP)
            DEV = string(class(obj));
            MSG = "RESP to <" + DEV + ">: """ + RESP + """";
            DEBUG_MSG(MSG, "orange");
        end
    end

    methods (Access = protected) % log wrapper for send/query
        function send_and_log(obj, CMD)
            arguments
                obj
                CMD (1,1) string {mustBeNonempty(CMD)}
            end
            obj.DEBUG_CMD_LOG(CMD);
            obj.con.send(CMD);
        end

        function resp = query_and_log(obj, CMD)
            arguments
                obj
                CMD (1,1) string {mustBeNonempty(CMD)}
            end
            obj.DEBUG_CMD_LOG(CMD);
            %FIXME: speed settings!
            resp = obj.con.query(CMD, "fast");
            obj.DEBUG_RESP_LOG(resp);
        end
    end
end










