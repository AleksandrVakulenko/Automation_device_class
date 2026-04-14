function [vias_adr, SerialNumber] = find_visa_dev_by_name(name, SerialNumber)
arguments
    name string
    SerialNumber = [];
end
    dev_table = visadevlist;
    ind = find(dev_table.Model == name);

    if ~isempty(ind)
        if ~isempty(SerialNumber)
            SerialNumber = string(SerialNumber);
            ind2 = find(dev_table.SerialNumber == SerialNumber);
            if any(ind == ind2)
                vias_adr = dev_table.ResourceName(ind2);
            else
                Str = adev_utils.get_dev_list_str(dev_table);
                error(['No device "' char(name) '"' ' with SN:' ...
                    char(SerialNumber) ' in list: ' newline Str]);
            end
        else % no SERIAL NUMBER is provided:
            if numel(ind) == 1
                vias_adr = dev_table.ResourceName(ind);
            else
                Str = adev_utils.get_dev_list_str(dev_table);
                error(['the choice of device ' '"' char(name) '"' ...
                    ' is ambiguous:' newline Str]);
            end
        end
    else
        Str = adev_utils.get_dev_list_str(dev_table);
        error(['No device "' char(name) '" in list: ' newline Str]);
    end

end