% Date: 2026.04.23
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: NCM lab
% Model: Temp controller V2
% Description: Single channel temperature controller
%
% ------------

% TODO:
% 1) Add temp_controller_traits
% 2) Add inheritance from temp_controller_traits
% 3) Add hardware description
% 4)


classdef TController2 < aDevice
    %--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = TController2(COM_port)
            [~, Full_address] = con_utils.VISA_parse_COM_string(COM_port);
            obj@aDevice(Connector_COM_USB(Full_address));
            disp(['TController2 connected at port: ' char(Full_address)])
        end

%         function delete(obj)
%             
%         end

        function [Temp, flags, trigger, stable] = read_temp(obj)
            Data = obj.get_bytes();

            Temp.temp = double(typecast(uint8(Data(1:4)),'uint32'))/10000;
            Temp.sp = double(typecast(uint8(Data(5:8)),'uint32'))/10000;
            Temp.gsp = double(typecast(uint8(Data(9:12)),'uint32'))/10000;
            
            % FIXME: magic constant
            Vout = double(typecast(uint8(Data(13:14)),'uint16'))/4096*12;
            
            % FIXME: magic constant
            Temp.power = (Vout/12)^2;
            
            serv1 = uint8(Data(15));
            serv2 = uint8(Data(16));

            flags.heating_flag = bitget(serv1, 1);
            flags.ramping = bitget(serv1, 2);
            flags.heating = bitget(serv1, 3);
            trigger.pin_state = bitget(serv1, 4);
            flags.lock = bitget(serv1, 5);
            stable = (flags.lock == 1) & (flags.ramping == 0);

            trigger.time = double(typecast(uint8(Data(17:20)),'uint32'))*1.00e-3;
        end
        
        %-------------------------------CMD---------------------------------
        function CMD_data_req(obj)
            obj.send_cmd([10 0 0 0 0]);
        end

        function feedback(obj, status)
            if status == "on"
                obj.send_cmd([15 0 0 0 0]);
            elseif status == "off"
                obj.send_cmd([15 0 1 0 0]);
            end
        end

        function Enable_heater(obj)
            obj.send_cmd([11 0 0 0 0]);
        end

        function Disable_heater(obj)
            obj.send_cmd([12 0 0 0 0]);
        end

        function Enable_12V(obj)
            obj.send_cmd([3 0 0 0 0]);
        end

        function Disable_12V(obj)
            obj.send_cmd([4 0 0 0 0]);
        end

        function Stop_ramping(obj)
            obj.send_cmd([13 0 0 0 0]);
        end

        function set_PID(obj, P, I, D, G)
            % FIXME: add PID value limits
            P = single(P);
            Bytes = flip(typecast(P, 'uint8'));
            CMD = uint8([16 Bytes]);
            obj.send_cmd(CMD);

            I = single(I);
            Bytes = flip(typecast(I, 'uint8'));
            CMD = uint8([17 Bytes]);
            obj.send_cmd(CMD);

            D = single(D);
            Bytes = flip(typecast(D, 'uint8'));
            CMD = uint8([18 Bytes]);
            obj.send_cmd(CMD);

            G = single(G);
            Bytes = flip(typecast(G, 'uint8'));
            CMD = uint8([19 Bytes]);
            obj.send_cmd(CMD);
        end

        function Sensor_res(obj, sensor_res)
            if sensor_res ~= 100 && sensor_res ~= 1000
                warning(['WRONG Sensor_res VALUE ' num2str(sensor_res)])
                sensor_res = 1000;
            end
            switch sensor_res
                case 100
                    ArgA = 1;
                case 1000
                    ArgA = 0;
            end
            obj.send_cmd([14 0 uint8(ArgA) 0 0]);
        end

        function Set_send_period(obj, period_ms) % ms
            period_ms = correct_value(period_ms, 10, 1000);
            period_ms = uint16(period_ms/1.25);
            bytes = flip(typecast(period_ms,'uint8'));
            obj.send_cmd([5 bytes 0 0]);
        end

        function Set_ramp(obj, target, speed)
            target = correct_value(target, 70, 650);
            speed = correct_value(speed, 0.1, 60);
            target_bytes = flip(typecast(uint16(target*100),'uint8'));
            speed_bytes = flip(typecast(uint16(speed*100),'uint8'));
            obj.send_cmd([7 target_bytes speed_bytes])
        end
        
        function Set_setpoint(obj, setpoint)
            setpoint = correct_value(setpoint, 70, 650);
            setpoint_bytes = flip(typecast(uint16(setpoint*100),'uint8'));
            obj.send_cmd([8 setpoint_bytes 0 0])
        end


        %----------------------------CMD_END--------------------------------
    end


    %-------------------------------PRIVATE--------------------------------
    properties (Access = private)
        Serial_obj = [];
        Wait_data_timeout = 1; %s
        number_of_bytes = 32;
    end

    methods (Access = private)

        function send_cmd(obj, CMD)
            obj.send_and_log(CMD);
%             write(obj.Serial_obj, uint8(CMD), "uint8");
            pause(0.012);
        end

        function Data = get_bytes(obj)
            obj.CMD_data_req;
            pause(0.1);
            Data = obj.read_and_log(obj.number_of_bytes, 'multiple');
            obj.flush_con();
        end

    end
end



% function port_name_check(port_name)
% Avilable_ports = serialportlist('available');
% 
% if ~(sum(Avilable_ports == port_name) == 1)
%     Text_ports_list = '';
%     for i = 1:numel(Avilable_ports)
%         Text_ports_list = [Text_ports_list char(Avilable_ports(i)) newline];
%     end
% 
%     msg = ['ERROR: No such com port name.' newline ...
%         'List of avilable ports:' newline ...
%         Text_ports_list ...
%         'Provided name: ' port_name];
%     error(msg)
% end
% end


% function serial_flush(serial_obj)
% pause(0.05) %FIXME: why pause?
% Bytes_count = serial_obj.NumBytesAvailable;
% if Bytes_count > 0
%     read(serial_obj, Bytes_count, "uint8");
% end
% end


% function [Value_X, Value_Y, CMD] = unpack_raw_bytes(Data_all)
% Bytes_01 = Data_all(1:4:end);
% Bytes_02 = Data_all(2:4:end);
% Bytes_03 = Data_all(3:4:end);
% Bytes_04 = Data_all(4:4:end);
%
% CMD_ind = find((Bytes_01 == 0x80) & (Bytes_02 == 0x00));
% if CMD_ind
%     CMD.flag = true;
%     CMD.high = Bytes_03(CMD_ind);
%     CMD.low = Bytes_04(CMD_ind);
%     Bytes_01(CMD_ind) = [];
%     Bytes_02(CMD_ind) = [];
%     Bytes_03(CMD_ind) = [];
%     Bytes_04(CMD_ind) = [];
% else
%     CMD.flag = false;
%     CMD.high = 0;
%     CMD.low = 0;
% end
%
% Bytes_01(Bytes_01>=128) = Bytes_01(Bytes_01>=128) - 256;
% Bytes_03(Bytes_03>=128) = Bytes_03(Bytes_03>=128) - 256;
%
% Value_X = (Bytes_01*256 + Bytes_02)*10/2^15;
% Value_Y = (Bytes_03*256 + Bytes_04)*10/2^15;
% end


function value = correct_value(value, low, high)
if value < low
    value = low;
end
if value > high
    value = high;
end
end



