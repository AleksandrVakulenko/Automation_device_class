% FIXME: move to con_utils
function GPIB_validation(GPIB_num)
mustBeNumeric(GPIB_num);
mustBeInteger(GPIB_num);
mustBeGreaterThanOrEqual(GPIB_num, 0);
mustBeLessThanOrEqual(GPIB_num, 30);
end
