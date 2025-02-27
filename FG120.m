

classdef FG120 < ADevice

    methods (Access = public)
        function obj = FG120(adr)
            obj@ADevice(Connector_GPIB(adr))
            disp("FG120 C-tor") % FIXME: debug
        end

        function delete(obj)
            disp("FG120 D-tor") % FIXME: debug
        end
    end

end