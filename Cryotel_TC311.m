
classdef Cryotel_TC311 < handle
    properties
        SerialObj
        BaudRate = 9600
    end

    methods (Access = public)
        function obj = Cryotel_TC311(COM_number)
            arguments
                COM_number
            end
            obj.SerialObj = serialport(COM_number, obj.BaudRate);
            flush(obj.SerialObj);
            disp(['TController Cryotel TC311 connected at port: ' char(COM_number)])
        end

        function delete(obj)
            if ~isempty(obj.SerialObj) && isvalid(obj.SerialObj)
                delete(obj.SerialObj);
            end
        end

        function flush(obj)
            flush(obj.SerialObj);
        end

        function resp = read(obj)
            try
                resp = readline(obj.SerialObj);
            catch ME
                error('CryoTel:ReadFailed', 'Read error: %s', ME.message);
            end
            resp = erase(string(resp), [char(13), newline, '"']); 
            resp = strtrim(resp);
            if strlength(resp) == 0
                error('CryoTel:EmptyResponse', 'EmptyResponse');
            end
        end

        function send(obj, CMD)
            writeline(obj.SerialObj, CMD);
            if ~(isstring(CMD) || ischar(CMD))
                error("CryoTel:InvalidCommand", ...
                "CMD must be string or char");
            end

            if strlength(string(CMD)) == 0
                error("CryoTel:EmptyCommand", "CMD couldn't be empty");
            end
        end

        function resp = query(obj, CMD)
            obj.send(CMD);
            resp = obj.read();
        end

        function resp = get_IDN(obj)
            resp = obj.query("*IDN?");
        end

    %---------- GET CMD public block ----------
        function temp = get_temperature(obj)
            resp = obj.query("MEASure:TEMPerature?");
            [v, i] = sscanf(resp, '%f');
            if i ~= 1
                error('scanf error');
            end
            temp = v;
        end

        function resp = get_resistance(obj)
            resp = obj.query("MEASure:RESistance?");
        end

        function resp = get_target_temperature(obj)
            obj.flush
            resp = obj.query("PID:TEMPerature:TARGet?");
        end

        function resp = get_PID_parameters(obj, parameter)
            if parameter == 'KP'
                resp = obj.query("PID:KP?");
            elseif parameter == 'KI'
                resp = obj.query("PID:KI?");
            elseif parameter == 'KD'
                resp = obj.query("PID:KD?");
            else
                error("CMD must be 'KP', 'KI' or 'KD'");
            end

        end

        function resp = get_heater_mode(obj)
            CMD = "HEATer:MODE?";
            resp = obj.query(CMD);
            switch resp
                case '"OFF"'
                    disp("The heater is OFF");
                case '"CC"'
                    disp("DC is supplied to the heater");
                case '"PID"'
                    disp("The heater is in PID control mode");
                otherwise
                    disp("Unknown mode: " + resp);
            end
        end

        function resp = get_sensor(obj)
            CMD = 'SENSOR?';
            resp = obj.query(CMD);
        end

        function resp = get_heater_current(obj)
            CMD = 'HEATer:CURRent:MEASured?';
            resp = obj.query(CMD); %A
            disp("Measured heater current is " + resp)
        end

        function resp = get_target_heater_current(obj)
            CMD = 'HEATer:CURRent?';
            resp = obj.query(CMD); %A
        end        


    %---------- SET CMD public block ----------
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

    end
end






