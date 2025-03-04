

classdef SR860_dev < aDevice

    methods (Access = public)
        function obj = SR860_dev(GPIB_num)
            arguments
                % FIXME: maybe list of values?
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB(GPIB_num))
        end
    end

    %------------ CMD public block -----------
    methods (Access = public)

        function varargout = set_generator(obj, amp_V, freq_Hz)
            arguments
                obj
                amp_V (1, 1) double {mustBeNumeric(amp_V), ...
                    mustBeInRange(amp_V, 1e-9, 2, "inclusive")}
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
            end

            if nargout == 0
                obj.set_gen_freq(freq_Hz);
                obj.set_gen_amp(amp_V);
            else
                amp = obj.set_gen_amp(amp_V);
                freq = obj.set_gen_freq(freq_Hz);
                varargout = set_argout(nargout, amp, freq);
            end
        end
    end

    %----------- CMD PRIVATE block -----------
    methods (Access = private)

        function varargout = set_gen_freq(obj, freq_Hz)
            arguments
                obj
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
            end
            CMD = sprintf("FREQINT %f HZ", freq_Hz);
            obj.con.send(CMD);
            obj.DEBUG_CMD_LOG(CMD)
            if nargout > 0
                freq = obj.get_gen_freq();
                varargout = set_argout(nargout, freq);
            end
        end

        function varargout = set_gen_amp(obj, amp_V)
            arguments
                obj
                amp_V (1, 1) double {mustBeNumeric(amp_V), ...
                    mustBeInRange(amp_V, 1e-9, 2, "inclusive")}
            end
            CMD = sprintf("SLVL %0.3f V", amp_V);
            obj.con.send(CMD);
            obj.DEBUG_CMD_LOG(CMD)
            if nargout > 0
                amp = obj.get_gen_amp();
                varargout = set_argout(nargout, amp);
            end
        end

        function freq_Hz = get_gen_freq(obj)
            CMD = "FREQINT?";
            resp = obj.con.query(CMD);
            freq_Hz = str2double(resp);
            obj.DEBUG_CMD_LOG(CMD)
        end

        function amp_V = get_gen_amp(obj)
            CMD = "SLVL?";
            resp = obj.con.query(CMD);
            amp_V = str2double(resp);
            obj.DEBUG_CMD_LOG(CMD)
        end

    end



end




function out = set_argout(n_out, varargin)
n_in = nargin-1;
if n_out > 0
    if n_in <= n_out
        for i = 1:n_in
            out{i} = varargin{i};
        end
        for i = n_in+1:n_out
            out{i} = [];
        end
    else % n_in > n_out
        for i = 1:n_out
            out{i} = varargin{i};
        end
    end
else
    out = {};
end
end


