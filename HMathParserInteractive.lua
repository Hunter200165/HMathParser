--[[
    HMathParserInteractive - interactive test program to test HMathParser lib
    Copyright, 2019-2020 (c) Hunter200165, All rights reserved

    This software is provided under modified MIT license, with changes:
      - Software cannot be modified and distributed or included in other software 
        with the goal of commercial profit without explicit agreement of all developers 
        of this software.
      - Any derived software, or software that includes this one must use these copyright 
        and license notices; That notes can be omitted by agreement of all developers of the 
        included software.
]]

local HMathParser = require 'HMathParser';

print('Type something and it will be evaluated.');
print('Write `exit!` to exit');

while not false do 
    io.write('>> ');
    local Str = io.read();

    if Str == 'exit!' then break; end;

    local Result = HMathParser.Compute(Str);
    if type(Result) == 'number' then 
        print(Result);
    else
        print('Error has occured: ' .. Result);
    end;
end;