

% TODO:
%  1) place IDC, RST to superclass
%  2) 
%  3) 




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


        function resp = read_last(obj)

            CMD = ":FETCh?";
            resp = obj.query_and_log(CMD);

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


    %----------- CMD PRIVATE block -----------
    methods (Access = private) % FIXME: make private (done)



    end
    %-----------------------------------------



    methods (Access = private) % log wrapper for send/query
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






