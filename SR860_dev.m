

% TODO:
%  1) SOFF p108
%  2) RSRC p109
%  3) REFZ 

%  4) IVMD p111
%  5) ISRC
%  6) ICPL (???)
%  7) IGND
%  8) IRNG (!!!)
%  9) ICUR (!!!)
% 10) ILVL p112

% 11) OFLT p113
% 12) OFSL
% 13) SYNC
% 14) ADVFILT

% 15) CEXP

% 16) COFA
% 17) COFP

% 18) OAUX (!)
% 19) AUXV (!)

% 20) OUTP? (!!!!) 
% 21) SNAP? (!!!)


% 22) Data Streaming Commands ? p140

% System Commands:
% 23) 
% 24) 
% 25) 



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


    %------------ SET CMD public block -----------
    methods (Access = public) % SET FUNCTIONS
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

        function set_sensitivity(obj, Level, mode)
            arguments
                obj
                Level (1,1) double
                mode {mustBeMember(mode, ["voltage", "current"])}
            end
            [~, ind] = find_best_sensitivity(Level, mode);
            CMD = sprintf("SCAL %d", ind);
            obj.send_and_log(CMD);
        end
    
        function set_detector_phase(obj, phase_deg)
            arguments
                obj
                phase_deg (1, 1) double {mustBeNumeric(phase_deg), ...
                    mustBeInRange(phase_deg, -360e3, 360e3, "inclusive")}
            end
                CMD = sprintf("PHAS %0.7d DEG", phase_deg);
                obj.send_and_log(CMD);
        end

        function set_harm_num(obj, harm_n)
            arguments
                obj
                harm_n (1,1) {mustBeNumeric(harm_n), ...
                    mustBeInRange(harm_n, 1, 99, "inclusive")}
            end
            if  harm_n ~= round(harm_n)
                harm_n = round(harm_n);
                warning(['Harmonic number rounded to ' num2str(harm_n)]);
            end
            CMD = sprintf("HARM %d", harm_n);
            obj.send_and_log(CMD);
        end

    end


    %------------ GET CMD public block -----------
    methods (Access = public) % GET FUNCTIONS
        function resp = get_IDN(obj)
            resp = obj.query_and_log("*IDN?");
        end
        
        function RESET(obj)
            obj.send_and_log("*RST");
        end

        function [amp_V, freq_Hz] = get_genVF(obj)
            amp_V = obj.get_gen_amp();
            freq_Hz = obj.get_gen_freq();
        end
    
        function phase_deg = get_detector_phase(obj)
            CMD = "PHAS?";
            resp = obj.query_and_log(CMD);
            phase_deg = str2double(resp);
            phase_deg = adev_utils.round_to_digit(phase_deg, 6);
        end
   
        function freq_Hz = get_detector_freq(obj)
            CMD = "FREQ?";
            resp = obj.query_and_log(CMD);
            freq_Hz = str2double(resp);
            freq_Hz = adev_utils.round_to_digit(freq_Hz, 4);
        end
   
        function harm_num = get_harm_num(obj)
            CMD = "HARM?";
            resp = obj.query_and_log(CMD);
            harm_num = str2double(resp);
        end
    end


    %----------- CMD PRIVATE block -----------
    methods (Access = private) % FIXME: make private (done)
        function varargout = set_gen_freq(obj, freq_Hz)
            arguments
                obj
                freq_Hz (1, 1) double {mustBeNumeric(freq_Hz), ...
                    mustBeInRange(freq_Hz, 0.001, 500e3, "inclusive")}
            end
            CMD = sprintf("FREQINT %f HZ", freq_Hz);
            obj.send_and_log(CMD);
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
            obj.send_and_log(CMD);
            if nargout > 0
                amp = obj.get_gen_amp();
                varargout = set_argout(nargout, amp);
            end
        end

        function freq_Hz = get_gen_freq(obj)
            CMD = "FREQINT?";
            resp = obj.query_and_log(CMD);
            freq_Hz = str2double(resp);
            freq_Hz = adev_utils.round_to_digit(freq_Hz, 4);
        end

        function amp_V = get_gen_amp(obj)
            CMD = "SLVL?";
            resp = obj.query_and_log(CMD);
            amp_V = str2double(resp);
            amp_V = adev_utils.round_to_digit(amp_V, 8);
        end

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

