

classdef SR860_dev < aDevice

    methods (Access = public)
        function obj = SR860_dev(GPIB_num)
            arguments
                % FIXME: maybe list of values?
                GPIB_num {adev_utils.GPIB_validation(GPIB_num)}
            end
            obj@aDevice(Connector_GPIB_fast(GPIB_num))
        end
    end

    %------------ CMD public block -----------
    methods (Access = public)

        function varargout = set_genVF(obj, amp_V, freq_Hz)
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

        function [amp_V, freq_Hz] = get_genVF(obj)
            amp_V = obj.get_gen_amp();
            freq_Hz = obj.get_gen_freq();
        end

        function set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, ["voltage", "current"])}
            end
            [~, ind] = find_best_sensitivity(Level, mode);
            CMD = sprintf("SCAL %d", ind);
            obj.DEBUG_CMD_LOG(CMD);
            obj.con.send(CMD);
        end
    end

    %----------- CMD PRIVATE block -----------
    methods (Access = public)

        function varargout = set_gen_freq(obj, freq_Hz)
            arguments
                obj
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
            end
            CMD = sprintf("FREQINT %f HZ", freq_Hz);
            obj.DEBUG_CMD_LOG(CMD)
            obj.con.send(CMD);
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
            obj.DEBUG_CMD_LOG(CMD)
            obj.con.send(CMD);
            if nargout > 0
                amp = obj.get_gen_amp();
                varargout = set_argout(nargout, amp);
            end
        end

        function freq_Hz = get_gen_freq(obj)
            CMD = "FREQINT?";
            obj.DEBUG_CMD_LOG(CMD)
            resp = obj.con.query(CMD, "fast");
            obj.DEBUG_RESP_LOG(resp);
            freq_Hz = str2double(resp);

        end

        function amp_V = get_gen_amp(obj)
            CMD = "SLVL?";
            obj.DEBUG_CMD_LOG(CMD)
            resp = obj.con.query(CMD, "fast");
            obj.DEBUG_RESP_LOG(resp);
            amp_V = str2double(resp);
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


function [sense, ind] = find_best_sensitivity(Level, mode)
arguments
    Level (1,1) double
    mode {mustBeMember(mode, ["voltage", "current"])}
end
Sens_array_V = [1, 500e-3, 200e-3, 100e-3, 50e-3, 20e-3, ...
    10e-3, 5e-3, 2e-3, 1e-3, 500e-6, 200e-6, 100e-6, 50e-6, ...
    20e-6, 10e-6, 5e-6, 2e-6, 1e-6, 500e-9, 200e-9, 100e-9, ...
    50e-9, 20e-9, 10e-9, 5e-9, 2e-9, 1e-9];
Sens_array_I = Sens_array_V/1e6;
switch mode
    case "voltage"
        Sens_array = Sens_array_V;
        Limit = 1; % V
    case "current"
        Sens_array = Sens_array_I;
        Limit = 1e-6; % A
end
if Level > Limit*1.1
    warning("Level of sensitivity is above maximum")
    Level = Limit;
end
ind = find(Sens_array<Level, 1);
if isempty(ind)
    ind = numel(Sens_array);
elseif ind > 1
    ind = ind - 1;
end
sense = Sens_array(ind);
ind = ind - 1;
end

