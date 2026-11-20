% Date: 2026.11.20
% Author: A. V. Deyneka, A. F. Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: https://cryotel.ru/
% Model: Temp controller TC311
% Description: Single channel temperature controller
%
% ------------

% TODO:
% 1) 
% 2) 
% 3) 
% 4)


classdef Cryotel_TC311 < aDevice
    properties
        % FIXME: empty
    end

    methods (Access = public)
        function obj = Cryotel_TC311(COM_port)
            arguments
                COM_port
            end
            [~, Full_address] = con_utils.VISA_parse_COM_string(COM_port);
            obj@aDevice(Connector_COM_USB(Full_address));
            disp(['TController Cryotel TC311 connected at port: ' char(Full_address)])
        end

        function delete(obj)
            % nothing to do here
        end

% NOTE: low level interaction
        function flush(obj)
            % FIXME: remove from public methods
            obj.flush_con(); % method from aDevice
        end

        function resp = read(obj)
            % FIXME: remove from public methods
            resp = obj.read_and_log(); % method from aDevice
        end

        function send(obj, CMD)
            % FIXME: remove from public methods
            if strlength(string(CMD)) == 0
                error("CryoTel:EmptyCommand", "CMD couldn't be empty");
            end
            obj.send_and_log(CMD); % method from aDevice
        end

        function resp = query(obj, CMD)
            % FIXME: remove from public methods
            resp = obj.query_and_log(CMD); % method from aDevice
        end

        function value = query_and_scan_one_value(obj, CMD)
            arguments
                obj
                CMD (1,1) string
            end
            resp = obj.query(CMD);
            [value, i] = sscanf(resp, '%f', 1);
            if i ~= 1 || isempty(value)
                error('scanf error');
            end
        end
% ---------------------------

% NOTE: GET CMD public block ----------
        function resp_str = get_IDN(obj)
            resp_str = obj.query("*IDN?");
        end

        function temp = get_temperature(obj)
            temp = obj.query_and_scan_one_value("MEASure:TEMPerature?");
        end

        function res = get_resistance(obj)
            res = obj.query_and_scan_one_value("MEASure:RESistance?");
        end

        function temp = get_target_temperature(obj)
            obj.flush; % FIXME: why?
            temp = obj.query_and_scan_one_value("PID:TEMPerature:TARGet?");
        end

        function value = get_PID_parameters(obj, parameter)
            arguments
                obj Cryotel_TC311
                parameter {mustBeMember(parameter, ...
                    ["KP", "KI", "KD", "all"])} = "all"
                % FIXME: "KP", "KI", "KD" options are only for 
                %        backward compatibility
            end
            if parameter == "all"
                CMD = ['PID:' char(parameter) '?'];
                value = obj.query_and_scan_one_value(CMD);
            else
                vP = obj.query_and_scan_one_value('PID:KP?');
                vI = obj.query_and_scan_one_value('PID:KI?');
                vD = obj.query_and_scan_one_value('PID:KD?');
                value = [vP vI vD];
            end
        end

        function resp = get_heater_mode(obj)
            resp = obj.query("HEATer:MODE?");
            switch resp
                case """OFF"""
                    resp = "The heater is OFF";
                case """CC"""
                    resp = "DC is supplied to the heater";
                case """PID"""
                    resp = "The heater is in PID control mode";
                otherwise
                    resp = string(['Unknown mode: <' char(resp) '>']);
            end
            disp(resp);
        end

        function resp = get_sensor(obj)
            % FIXME: check this
            CMD = 'SENSOR?';
            resp = obj.query(CMD);
        end

        function cur = get_heater_current(obj)
            cur = obj.query_and_scan_one_value("HEATer:CURRent:MEASured?"); % [A]
        end

        function cur = get_target_heater_current(obj)
             cur = obj.query_and_scan_one_value("HEATer:CURRent?"); % [A]
        end
% -------------------------------------

% NOTE: SET CMD public block ----------
        function set_target_temperature(obj, trg_temp)
            CMD = "PID:TEMPerature:TARGet " + num2str(trg_temp);
            obj.send(CMD)
            disp("Target temperature set on " + obj.get_target_temperature + " K");
        end
        
        function go_to_target_temperature(obj)
            obj.set_heater_mode("PID")
            temperature = round(str2double(obj.get_temperature), 1);

            while temperature ~= str2double(obj.get_target_temperature)
                temperature = round(str2double(obj.get_temperature), 1);
                disp(temperature);
                obj.get_heater_mode;
                pause(0.5)
            end
            obj.set_heater_mode("OFF")
        end
        

        function set_KP(obj, KP)
            CMD = "PID:KP " + num2str(KP);
            obj.send(CMD)
            disp("Target PID KP set on " + KP);
        end

        function set_KI(obj, KI)
            CMD = "PID:KI " + num2str(KI);
            obj.send(CMD)
            disp("Target PID KI set on " + KI);
        end

        function set_KD(obj, KD)
           CMD = "PID:KD " + num2str(KD);
           obj.send(CMD)
           disp("Target PID KD set on " + KD);
        end

        function set_heater_mode (obj, mode)
            arguments
                obj
                mode {mustBeMember(mode, ["OFF", "DC", "PID"])}
            end
            pause_constant = 0.1;
            switch mode
                case "OFF"
                    CMD = "HEATer:MODE:OFF";
                    obj.send(CMD);
                    pause(pause_constant);
                    obj.get_heater_mode;
                case "DC"
                    CMD = "HEATer:MODE:CC";
                    obj.send(CMD);
                    pause(pause_constant);
                    obj.get_heater_mode;               
                case "PID"
                    CMD = "HEATer:MODE:PID";
                    obj.send(CMD);
                    pause(pause_constant);
                    obj.get_heater_mode;
                otherwise
                    error("Heater mode must be 'OFF' 'DC' or 'PID'")
            end
        end

        function set_heater_current(obj, current)
            current_min = 0; % A
            current_max = 1; % A
            if current < current_min
                current = current_min;
                 disp("The requested current value is lower " + ...
                     "than the minumum value acceptable range. " + ...
                     "The heater current value is set to " + ...
                    current_min + " A");
            end

            if current > current_max
                current = current_max;
                 disp("The requested current value is greater " + ...
                     "than the maximum value acceptable range. " + ...
                     "The heater current value is set to " + ...
                    current_max + " A");
            end

            pause_constant = 0.1;
            CMD = ['HEATer:CURRent ' num2str(current)];
            obj.send(CMD);
            pause(pause_constant);
            obj.get_heater_current; 
        end
% -------------------------------------

    end % methods

end % classdef






