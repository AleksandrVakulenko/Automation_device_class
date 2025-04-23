
clc

Level_list = 10.^linspace(log10(0.01), log10(1e-10), 500);

Sense_arr = [];
for i = 1:numel(Level_list)

Level = Level_list(i);

if Level > 1e-3
    Level = 1e-3;
end
if Level < 1e-9
    Level = 1e-9;
end
Level_exp = -fix(log10(Level)-0.999);
if Level_exp < 3
    Level_exp = 3;
end

% disp([num2str(Level_list(i)) ' ' num2str(Level_exp)])
Sense_arr(i) = Level_exp;
end


Sense_arr = 10.^Sense_arr;

Voltege = Sense_arr.*Level_list;

plot(Level_list, Voltege)
set(gca, 'xscale', 'log')
set(gca, 'yscale', 'log')




