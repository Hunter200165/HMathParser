--[[
    HMathParser - calculator, that can evaluate strings
    Copyright, 2019-2020 (c) Hunter200165, All rights reserved

    This software is provided under modified MIT license, with changes:
      - Software cannot be modified and distributed or included in other software 
        with the goal of commercial profit without explicit agreement of all developers 
        of this software.
      - Any derived software, or software that includes this one must use these copyright 
        and license notices; That notes can be omitted by agreement of all developers of the 
        included software.
]]

local HMathParser = { };

local bit = require 'bit';

HMathParser.BinaryOperators = {  
    ['**'] = 0;
    ['^'] = 0;

    ['band'] = 1;
    ['&'] = 1;
    ['bor'] = 2;
    ['|'] = 2;
    ['bxor'] = 2;
    ['~^'] = 2;
    ['shl'] = 3;
    ['<<'] = 3;
    ['shr'] = 3;
    ['>>'] = 3;
    --[[ Enable it only if bit lib supports that. And you will need to write an implementation for those opcodes! ]]
    -- ['rol'] = 3;
    -- ['<<<'] = 3;
    -- ['ror'] = 3;
    -- ['>>>'] = 3;
    
    ['*'] = 4;
    ['/'] = 4;
    ['//'] = 4;
    ['/^'] = 4;
    ['div'] = 4;
    ['updiv'] = 4;
    ['%'] = 4;
    ['mod'] = 4;

    ['+'] = 5;
    ['-'] = 5;

    ['=='] = 6;
    ['!='] = 6;
    ['>='] = 6;
    ['<='] = 6;
    ['>'] = 6;
    ['<'] = 6;
    
    ['and'] = 7;
    ['&&'] = 7;
    ['or'] = 8;
    ['||'] = 8;
    ['xor'] = 8;

    ['='] = 9;
};

HMathParser.OpCodes = { };

local OpCodes = HMathParser.OpCodes;

OpCodes.OP_EXP = 0;
OpCodes.OP_BAND = 1;
OpCodes.OP_BOR = 2;
OpCodes.OP_SHL = 3;
OpCodes.OP_SHR = 4;
OpCodes.OP_ROL = 5;
OpCodes.OP_ROR = 6;
OpCodes.OP_MUL = 7;
OpCodes.OP_DIV = 8;
OpCodes.OP_FLDIV = 9;
OpCodes.OP_UPDIV = 10;
OpCodes.OP_MOD = 11;
OpCodes.OP_ADD = 12;
OpCodes.OP_SUB = 13;
OpCodes.OP_EQ = 14;
OpCodes.OP_NEQ = 15;
OpCodes.OP_GE = 16;
OpCodes.OP_LE = 17;
OpCodes.OP_GT = 18;
OpCodes.OP_LT = 19;
OpCodes.OP_AND = 20;
OpCodes.OP_OR = 21;
OpCodes.OP_XOR = 22;
OpCodes.OP_MOV = 23;

HMathParser.BinaryOpcodes = {
    ['**']    = OpCodes.OP_EXP;
    ['^']     = OpCodes.OP_EXP;

    ['band']  = OpCodes.OP_BAND;
    ['&']     = OpCodes.OP_BAND;
    ['bor']   = OpCodes.OP_BOR;
    ['|']     = OpCodes.OP_BOR;
    ['bxor']  = OpCodes.OP_BXOR;
    ['~^']    = OpCodes.OP_BXOR;
    ['shl']   = OpCodes.OP_SHL;
    ['<<']    = OpCodes.OP_SHL;
    ['shr']   = OpCodes.OP_SHR;
    ['>>']    = OpCodes.OP_SHR;
    --[[ Enable it only if bit lib supports that. And you will need to write an implementation for those opcodes! ]]
    -- ['rol']   = OpCodes.OP_ROL;
    -- ['<<<']   = OpCodes.OP_ROL;
    -- ['ror']   = OpCodes.OP_ROR;
    -- ['>>>']   = OpCodes.OP_ROR;

    ['*']     = OpCodes.OP_MUL;
    ['/']     = OpCodes.OP_DIV;
    ['//']    = OpCodes.OP_FLDIV;
    ['/^']    = OpCodes.OP_UPDIV;
    ['div']   = OpCodes.OP_FLDIV;
    ['updiv'] = OpCodes.OP_UPDIV;
    ['%']     = OpCodes.OP_MOD;
    ['mod']   = OpCodes.OP_MOD;

    ['+']     = OpCodes.OP_ADD;
    ['-']     = OpCodes.OP_SUB;

    ['==']    = OpCodes.OP_EQ;
    ['!=']    = OpCodes.OP_NEQ;
    ['>=']    = OpCodes.OP_GE;
    ['<=']    = OpCodes.OP_LE;
    ['>']     = OpCodes.OP_GT;
    ['<']     = OpCodes.OP_LT;

    ['and']   = OpCodes.OP_AND;
    ['&&']    = OpCodes.OP_AND;
    ['or']    = OpCodes.OP_OR;
    ['||']    = OpCodes.OP_OR;
    ['xor']   = OpCodes.OP_XOR;

    ['=']     = OpCodes.OP_MOV;
};

HMathParser.PrefixOperators = {
    ['-'] = 1;
    ['~'] = 2;
    ['bnot'] = 2;
    ['!'] = 3;
    ['not'] = 3;
};

OpCodes.OP_NEG = 24;
OpCodes.OP_BNOT = 25;
OpCodes.OP_NOT = 26;

HMathParser.PrefixOpCodes = {
    ['-'] = OpCodes.OP_NEG;
    ['~'] = OpCodes.OP_BNOT;
    ['bnot'] = OpCodes.OP_BNOT;
    ['!'] = OpCodes.OP_NOT;
    ['not'] = OpCodes.OP_NOT;
};

OpCodes.OP_PVAR = 27;
OpCodes.OP_CALL = 28;
OpCodes.OP_PNUM = 29;

local function raise(AMsg, ...)
    error(string.format(AMsg, ...));
end;

local CharTypes = {
    Identifier = 1;
    BraceOpened = 2;
    BraceClosed = 3;
    Separator = 4;
    Whitespace = 5;
    Operator = 6;
    Number = 7;
};

local TExecutionContext = { 
    MaxVariableCount = 256;
    Functions = { };
};

function TExecutionContext.Create()
    local Object = { };
    for k,v in pairs(TExecutionContext) do 
        Object[k] = v;
    end;
    Object.Variables = { };

    Object.Variables['$pi'] = math.pi;
    Object.Variables['$e'] = math.exp(1); 

    Object.Functions = { };
    for k,v in pairs(TExecutionContext.Functions) do 
        Object.Functions[k] = v;
    end;

    return Object;
end;

local function EnsureParameters(Count, ...)
    local Args = { ... };
    if (#Args ~= Count) then 
        raise ('Expected %d parameters, but got %d', Count, #Args);
    end;
    
    return unpack(Args);
end;

function TExecutionContext.Functions.abs(...)
    return math.abs(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.sin(...)
    return math.sin(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.cos(...)
    return math.cos(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.tan(...)
    return math.tan(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.sinh(...)
    return math.sinh(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.cosh(...)
    return math.cosh(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.tanh(...)
    return math.tanh(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.min(...)
    return math.min(...);
end;

function TExecutionContext.Functions.max(...)
    return math.max(...);
end;

function TExecutionContext.Functions.deg(...)
    return math.deg(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.rad(...)
    return math.rad(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.exp(...)
    return math.exp(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.floor(...)
    return math.floor(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.ceil(...)
    return math.ceil(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.random(...)
    return math.random(...);
end;

function TExecutionContext.Functions.sqrt(...)
    return math.sqrt(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.ln(...)
    return math.log(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.log10(...)
    return math.log10(EnsureParameters(1, ...));
end;

function TExecutionContext.Functions.log(...)
    local A, Base = EnsureParameters(2, ...);
    return math.log(A) / math.log(Base);
end;

local TNode = { 
    OpCode = -1;
};

function TNode.Create(Content, OpCode)
    local Object = { };
    for k,v in pairs(TNode) do 
        Object[k] = v;
    end;

    Object.Content = Content;
    Object.OpCode = OpCode;
    Object.Operands = { };

    return Object;
end;

function TNode:GetContent(AContext)
    local Operands = self.Operands;
    if self.OpCode == OpCodes.OP_PNUM then 
        return Operands[1];
    elseif self.OpCode == OpCodes.OP_PVAR then 
        return AContext.Variables[self.Content] or raise ('EExecutionException: Variable not set : `%s`', self.Content);
    elseif self.OpCode == OpCodes.OP_MOV then 
        local Result = Operands[2]:GetContent(AContext);
        local Var = Operands[1].Content:match('^(%$%w+)$');
        if not Var then raise ('EExecutionException: Previous cannot be set, as it is not a variable: `%s`', Operands[1].Content); end;
        if not AContext.Variables[Var] and (#AContext.Variables >= AContext.MaxVariableCount) then 
            raise ('EExecutionException: Cannot set variable `%s` - variable quota limit exceeded.', Var);
        end;
        AContext.Variables[Var] = Result;
        return Result;
    elseif self.OpCode == OpCodes.OP_EXP then 
        return Operands[1]:GetContent(AContext) ^ Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_ADD then 
        return Operands[1]:GetContent(AContext) + Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_SUB then 
        return Operands[1]:GetContent(AContext) - Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_AND then 
        return ((Operands[1]:GetContent(AContext) ~= 0) and (Operands[2]:GetContent(AContext) ~= 0)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_OR then 
        return ((Operands[1]:GetContent(AContext) ~= 0) or (Operands[2]:GetContent(AContext) ~= 0)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_XOR then 
        return ((Operands[1]:GetContent(AContext) ~= 0) ~= (Operands[2]:GetContent(AContext) ~= 0)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_BAND then 
        return bit.band(Operands[1]:GetContent(AContext), Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_BOR then 
        return bit.bor(Operands[1]:GetContent(AContext), Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_BXOR then 
        return bit.bxor(Operands[1]:GetContent(AContext), Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_SHL then 
        return bit.lshift(Operands[1]:GetContent(AContext), Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_SHR then 
        return bit.rshift(Operands[1]:GetContent(AContext), Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_MUL then 
        return Operands[1]:GetContent(AContext) * Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_DIV then 
        return Operands[1]:GetContent(AContext) / Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_FLDIV then 
        return math.floor(Operands[1]:GetContent(AContext) / Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_UPDIV then 
        return math.ceil(Operands[1]:GetContent(AContext) / Operands[2]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_MOD then 
        return Operands[1]:GetContent(AContext) % Operands[2]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_EQ then 
        return (Operands[1]:GetContent(AContext) == Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_NEQ then 
        return (Operands[1]:GetContent(AContext) ~= Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_GE then 
        return (Operands[1]:GetContent(AContext) >= Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_LE then 
        return (Operands[1]:GetContent(AContext) <= Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_GT then 
        return (Operands[1]:GetContent(AContext) > Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_LT then 
        return (Operands[1]:GetContent(AContext) < Operands[2]:GetContent(AContext)) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_NEG then 
        return -Operands[1]:GetContent(AContext);
    elseif self.OpCode == OpCodes.OP_NOT then 
        return not (Operands[1]:GetContent(AContext) ~= 0) and 1 or 0;
    elseif self.OpCode == OpCodes.OP_BNOT then 
        return bit.bnot(Operands[1]:GetContent(AContext));
    elseif self.OpCode == OpCodes.OP_CALL then 
        local FuncName = self.Content;
        if not AContext.Functions[FuncName] then 
            raise ('EExecutionException: Unknown function to call : `%s`', FuncName);
        end;
        local Parameters = { };
        for i = 1, #Operands do 
            Parameters[i] = Operands[i]:GetContent(AContext);
        end;
        local Success, AOut = pcall(function()
            return AContext.Functions[FuncName](unpack(Parameters));
        end);
        if not Success then 
            raise ('EExecutionException: Error calling a function (%s) : %s', self.Content, tostring(AOut));
        end;
        local Result = tonumber(AOut);
        if not Result then 
            raise ('EExecutionException: Function call provided invalid type of output (%s)', self.Content);
        end;
        return Result;
    else 
        raise ('EExecutionException: Unknown operand to do: `%s`', tostring(self.OpCode));
    end;
end;

local Brackets = { ['('] = ')'; ['['] = ']'; ['{'] = '}'; };

function HMathParser.GetCharType(AChar)
    if (AChar == ',') or (AChar == ';') then 
        return CharTypes.Separator;
    elseif (AChar == '(') or (AChar == '[') or (AChar == '{') then 
        return CharTypes.BraceOpened;
    elseif (AChar == ')') or (AChar == ']') or (AChar == '}') then 
        return CharTypes.BraceClosed;
    elseif (AChar:match('%w')) then 
        return CharTypes.Identifier;
    elseif (AChar:match('%s')) then 
        return CharTypes.Whitespace;
    else
        return CharTypes.Operator;
    end;
end;

local function Concat(...) return table.concat { ... }; end;

function HMathParser.Compute(Str)
    local Err, Msg = pcall(function()
        local Tokens = HMathParser.GetTokens(Str);

        local ToExec = HMathParser.CompileAllExpressions(Tokens);
        
        local AContext = TExecutionContext.Create();

        local Result = 0;
        for i = 1, #ToExec do 
            Result = ToExec[i]:GetContent(AContext);
        end;

        return Result;
    end);

    --[[ Will return either a result, or a message of exception ]]
    return Msg;
end;

function HMathParser.GetTokens(Str)
    local Result = { };

    local CurString = '';
    local Position = 1;
    local Length = Str:len();

    local PrevType = 0;
    local CurType = 0;
    while Position <= Length do 
        local CurChar = Str:sub(Position, Position);
        CurType = HMathParser.GetCharType(CurChar);
        
        if (CurType ~= CharTypes.BraceOpened) and (CurType ~= CharTypes.BraceClosed) and ((CurType == PrevType) or (PrevType == 0)) then 
            CurString = Concat(CurString, CurChar);
            PrevType = CurType;
        else 
            if PrevType ~= CharTypes.Whitespace then 
                Result[#Result + 1] = {
                    Data = CurString;
                    Type = (PrevType == CharTypes.Identifier) and (tonumber(CurString) and CharTypes.Number or CharTypes.Identifier) or PrevType;
                };
            end;

            CurString = CurChar;
            PrevType = CurType;
        end;

        Position = Position + 1;
    end;

    Result[#Result + 1] = { 
        Data = CurString;
        Type = (CurType == CharTypes.Identifier) and (tonumber(CurString) and CharTypes.Number or CharTypes.Identifier) or CurType;
    };

    return Result;
end;

function HMathParser.GetBinaryOperatorOpCode(AOp)
    local OpCode = HMathParser.BinaryOpcodes[AOp];
    if not OpCode then 
        raise ('EInvalidArgumemt: Invalid operator passed to resolve opcode of: `%s`', AOp or '');
    end;
    return OpCode;
end;

function HMathParser.GetPrefixOperatorOpCode(AOp)
    local OpCode = HMathParser.PrefixOpCodes[AOp];
    if not OpCode then 
        raise ('EInvalidArgument: Invalid operator passed to resolve opcode of: `%s`', AOp or '');
    end;
    return OpCode;
end;

function HMathParser.GetPriorOperator(Tokens, From, UpTo)
    local Position = -1;
    local Result = -1;

    --[[ Getting binary operators! ]]
    local i = From;
    if Tokens[i].Type == CharTypes.BraceOpened then 
        i = HMathParser.GetPairingBracketPosition(Tokens, Tokens[i].Data, i + 1, UpTo); 
    else
        i = From + 1;
    end;
    while i < UpTo do 
        local Current = Tokens[i];

        if Current.Type == CharTypes.BraceOpened then 
            --[[ Getting position of closing bracket, and then incrementing it ]]
            i = HMathParser.GetPairingBracketPosition(Tokens, Current.Data, i + 1, UpTo);
        else 
            local Priority = HMathParser.BinaryOperators[Current.Data];

            if Priority then 
                if (Result < 0) or (Result < Priority) then 
                    Result = Priority;
                    Position = i;
                end;
            end;
        end;

        i = i + 1;
    end;

    return Position;
end;

function HMathParser.GetPairingBracketPosition(Tokens, Bracket, From, UpTo)
    local Closing = Brackets[Bracket];
    if not Closing then 
        raise('EInvalidBracket: %s is not a bracket', Bracket);
    end;

    local Count = 1;

    for i = From, UpTo do 
        local Current = Tokens[i].Data;
        if Current == Bracket then 
            Count = Count + 1;
        elseif Current == Closing then 
            Count = Count - 1;
        end;
        if Count <= 0 then 
            return i;
        end;
    end;

    raise ('EBracketNotEnclosed: Bracket `%s` is not paired!', Bracket);
end;

function HMathParser.CompileAllExpressions(Tokens)
    local AExpressions = { { } };

    --[[ All expressions are divided by `;` separator ]]
    local Depth = 1;
    local Ind = 1;
    for i = 1, #Tokens do 
        if Tokens[i].Data == ';' then 
            Depth = Depth + 1;
            AExpressions[Depth] = { };
            Ind = 1;
        else
            AExpressions[Depth][Ind] = Tokens[i];
            Ind = Ind + 1;
        end;
    end;

    local Result = { };
    for i = 1, #AExpressions do 
        Result[i] = HMathParser.BuildAST(AExpressions[i], 1, #AExpressions[i]);
    end;
    return Result;
end;

function HMathParser.CompileSimpleExpression(Tokens, From, UpTo)
    if From > UpTo then 
        raise ('ESyntaxException: Simple expression violates its bounds!');
    end;

    if HMathParser.PrefixOperators[Tokens[From].Data] then
        --[[ Prefixed! ]]
        local Node = TNode.Create(Tokens[From].Data, HMathParser.GetPrefixOperatorOpCode(Tokens[From].Data));
        Node.Operands[1] = HMathParser.CompileSimpleExpression(Tokens, From + 1, UpTo);

        return Node;
    end;

    local Current = Tokens[From];
    if (Current.Type == CharTypes.BraceOpened) then 
        if not (Current.Data == '(') then 
            raise ('ESyntaxException: Invalid bracket was used, only `()` is allowed!');
        else
            local Resolved = HMathParser.GetPairingBracketPosition(Tokens, Current.Data, From + 1, UpTo);
            if not (Resolved == UpTo) then 
                raise ('ESyntaxException: Invalid closing bracket position - it is expected only at the end of an expression!');
            end;
            return HMathParser.BuildAST(Tokens, From + 1, UpTo - 1);
        end;
    end;

    if Current.Data == '$' then 
        --[[ Variable prefix ]]
        if ((From + 1) > UpTo) or (Tokens[From + 1].Type ~= CharTypes.Identifier) then 
            raise ('ESyntaxException: Variable prefix `$` should be followed by identifier!');
        end;
        if not ((From + 1) == UpTo) then 
            raise ('ESyntaxException: Variable prefixed with `$` should stay at the end of expression.');
        end;
        return TNode.Create('$' .. Tokens[From + 1].Data, OpCodes.OP_PVAR);
    end;

    if Current.Type == CharTypes.Number then 
        if not (From == UpTo) then 
            raise ('ESyntaxException: Number should stay at the end of expression!');
        end;
        local Node = TNode.Create(Current.Data, OpCodes.OP_PNUM);
        Node.Operands[1] = tonumber(Current.Data) or raise ('ESyntaxException: %s is not a valid number!', Current.Data);
        return Node;
    end;

    --[[ Function call ]]
    if not (Current.Type == CharTypes.Identifier) then 
        raise ('ESyntaxException: Expected identifier, but got `%s`', Current.Data);
    end;

    if ((From + 1) > UpTo) or (Tokens[From + 1].Type ~= CharTypes.BraceOpened) then 
        raise ('ESyntaxException: Function call should follow the identifier!');
    end;

    if not (HMathParser.GetPairingBracketPosition(Tokens, Tokens[From + 1].Data, From + 2, UpTo) == UpTo) then 
        raise ('ESyntaxException: Function call should end at the end of expression!');
    end;

    local Node = TNode.Create(Current.Data, OpCodes.OP_CALL);

    if (From + 2 > UpTo - 1) then 
        --[[ No arguments! ]]
        return Node;
    end; 

    local Commas = { };
    local Pos = From + 2;
    while Pos < UpTo do 
        local Cur = Tokens[Pos];

        if Cur.Type == CharTypes.BraceOpened then 
            Pos = HMathParser.GetPairingBracketPosition(Tokens, Cur.Data, Pos + 1, UpTo - 1);
        elseif Cur.Data == ',' then 
            Commas[#Commas + 1] = Pos;
        end;
        Pos = Pos + 1;
    end;

    local Pos = From + 1;
    for i = 1, #Commas do 
        Node.Operands[i] = HMathParser.BuildAST(Tokens, Pos + 1, Commas[i] - 1);
        Pos = Commas[i];
    end;
    Node.Operands[#Commas + 1] = HMathParser.BuildAST(Tokens, Pos + 1, UpTo - 1);

    return Node;
end;

function HMathParser.BuildAST(Tokens, From, UpTo)
    if From > UpTo then 
        raise ('ESyntaxException: Expression violates its bounds! (Expression is empty)');
    end;

    local Result = { };

    local Op = HMathParser.GetPriorOperator(Tokens, From, UpTo);

    if Op >= 0 then 
        --[[ There is an operator ]]
        local Operator = Tokens[Op];

        local Node = TNode.Create(Operator.Data, HMathParser.GetBinaryOperatorOpCode(Operator.Data));
        Node.Operands[1] = HMathParser.BuildAST(Tokens, From, Op - 1);
        Node.Operands[2] = HMathParser.BuildAST(Tokens, Op + 1, UpTo);

        return Node;
    else
        return HMathParser.CompileSimpleExpression(Tokens, From, UpTo);  
    end;
end;

return HMathParser;