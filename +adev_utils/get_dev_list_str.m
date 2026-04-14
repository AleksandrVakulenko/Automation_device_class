function Str = get_dev_list_str(dev_table)
    arguments
        dev_table = [];
    end

    if isempty(dev_table)
        dev_table = visadevlist;
    end
    Str = '';
    for i = 1:size(dev_table, 1)
        Str = [Str num2str(i) '| ' ...
               char(dev_table{i, "Vendor"}) ' | ' ...
               char(dev_table{i, "Model"})  ' | ' ...
               char(dev_table{i, "SerialNumber"}) newline];
    end
end
