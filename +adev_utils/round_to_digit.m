function out = round_to_digit(value, digit)
    out = round(value*10^digit)/10^digit;
end