% Date: 2026.04.20
% Author: Aleksandr Vakulenko
% Licensed after GNU GPL v3
%
% ----INFO----:
% <Class for instrument control>
% Manufacturer: Keysight
% Model: E4980
% Description: LCR meter
% 
% ------------

% TODO:
% 1) rename class
% 2) read about ":FETCh:IMPedance:FORmatted?" and ":FETCh:IMPedance:CORrected?"

classdef LCR_E4980 < handle
    %--------------------------------PUBLIC--------------------------------
    methods (Access = public)
        function obj = LCR_E4980(Serial_number)
            arguments
                Serial_number = []
            end
            [vias_adr, SN] = con_utils.find_visa_dev_by_name("E4980AL", ...
                Serial_number, ["USB", "GPIB"]);
            if ~isempty(vias_adr)
				%TODO: add variants on VISA vendor
                obj.visa_dev = visa('ni', vias_adr); %new visadev is bad, we use old
            else
                error('connection error');
            end
        end

        
        function delete(obj)
             delete(obj.visa_dev); %FIXME: use it or not?
        end

    
        function volt_out = set_volt(obj, volt_in)
            obj.send([':VOLTage:LEVel ' num2str(volt_in)]);
            response = obj.query(':VOLTage:LEVel?');
            data = sscanf(response, '%f');
            volt_out = data(1);
        end


        function freq_out = set_freq(obj, freq_in)
            obj.send([':FREQuency:CW ' num2str(freq_in)]);
            response = obj.query(':FREQuency:CW?');
            data = sscanf(response, '%f');
            freq_out = data(1);
        end


        function [res_re, res_im] = get_res(obj)
            response = obj.query(':FETCh:IMPedance:CORrected?');
            data = sscanf(response, '%f,%f');
            res_re = data(1);
            res_im = data(2);
        end


        function [cap_re, tan_d] = get_cap(obj)
            response = obj.query(':FETCh:IMPedance:FORmatted?');
            data = sscanf(response, '%f,%f');
            cap_re = data(1);
            tan_d = data(2);
        end


        function set_speed(obj, arg, count)
            count = uint8(count);
            switch lower(arg)
                case 's'
                    CMD = [':APERture SHORt, ' num2str(count)];
                case 'm'
                    CMD = [':APERture MEDium, ' num2str(count)];
                case 'l'
                    CMD = [':APERture LONG, ' num2str(count)];
                otherwise
                    CMD = ':APERture MEDium, ';
            end
            obj.send(CMD);
        end


    end
    
    %-------------------------------PRIVATE--------------------------------
    properties (Access = private)
        visa_dev = [];
        send_data_timeout = 0.2; %s
    end
    
    methods (Access = private)
        function send(obj, CMD)
            dev = obj.visa_dev;
            fopen(dev);
            fprintf(dev, CMD);
            fclose(dev);
        end

        function response = query(obj, CMD)
            dev = obj.visa_dev;
            fopen(dev);
            fprintf(dev, CMD);
            response = fscanf(dev);
            fclose(dev);
        end
    end
    
end



