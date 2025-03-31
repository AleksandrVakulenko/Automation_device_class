

% TODO:
%  1) 





classdef K6517b_dev < aDevice

    methods (Access = public)
        function obj = K6517b_dev(GPIB_num)
            arguments
                % FIXME: maybe list of values?
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB_fast(GPIB_num))
        end
    end


    %------------ SET CMD public block -----------
    methods (Access = public) % SET FUNCTIONS

        function config(obj, mode)
            arguments
                obj
                mode {mustBeMember(mode, ["volt", "current", "res", "charge"])}
            end
            switch mode
                case "volt"
                    CMD = ":CONFigure:VOLTage";
                case "current"
                    CMD = ":CONFigure:CURRent";
                case "res"
                    CMD = ":CONFigure:RESistance";
                case "charge"
                    CMD = ":CONFigure:CHARge";
                otherwise
                    error('placeholder') % FIXME
            end
            obj.send_and_log(CMD);
        end

        function set_zero_check(obj, state)
        arguments
            obj
            state (1,1) string {mustBeMember(state, ["enable", "disable"])}
        end
            if state == "enable"
                CMD = ":SYSTem:ZCHeck ON";
            else
                CMD = ":SYSTem:ZCHeck OFF";
            end
            obj.send_and_log(CMD);
        end

        function resp = read_last(obj)

            CMD = ":FETCh?";
            resp = obj.query_and_log(CMD);

        end


        function set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, ["voltage", "current"])} = "current";
            end
            
            if mode == "voltage"
                func = "VOLTage";
            else
                func = "CURRent";
            end

            CMD = sprintf(":SENSe:%s:RANGe %d", func, Level);
            % ":SENSe:%s:RANGe ?"
            
            obj.send_and_log(CMD);
        end 


%         function set_sensitivity(obj, Level, mode)
%             arguments
%                 obj
%                 Level (1,1) double
%                 mode {mustBeMember(mode, ["voltage", "current"])}
%             end
%             [~, ind] = find_best_sensitivity(Level, mode);
%             CMD = sprintf("SCAL %d", ind);
%             obj.send_and_log(CMD);
%         end
    




    end


    %------------ GET CMD public block -----------
    methods (Access = public) % GET FUNCTIONS
        function resp = get_IDN(obj)
            resp = obj.query_and_log("*IDN?");
        end
        
        function RESET(obj)
            obj.send_and_log("*RST");
        end


    


    end


end






