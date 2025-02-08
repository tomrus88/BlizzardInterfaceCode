function CallErrorHandler(...)
	SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
	local result = geterrorhandler()(...);
	SetErrorCallstackHeight(nil);
	return result;
end

function GetErrorData()
	-- Example of how debug stack level is calculated
	-- Current stack: [1, 2, 3, 4, 5] (current function is at 1, total current height is 5)
	-- Stack at time of error: [1, 2] (these are currently now index 4 and 5, but at the time of error the stack height is 2)
	-- To calcuate the level to debug (4): curentStackHeight - (errorStackHeight - 1) = 5 - (2 - 1) = 4
	local currentStackHeight = GetCallstackHeight();
	local errorCallStackHeight = GetErrorCallstackHeight();
	local errorStackOffset = errorCallStackHeight and (errorCallStackHeight - 1);
	local debugStackLevel = currentStackHeight - (errorStackOffset or 0);
	local skipFunctionsAndUserdata = true;

	local stack = debugstack(debugStackLevel);
	local locals = debuglocals(debugStackLevel, skipFunctionsAndUserdata);
	locals = string.gsub(locals, "|([kK])", "%1");
	
	return stack, locals;
end

function assertsafe(cond, msgStringOrFunction, ...)
	if not cond then
		local error = msgStringOrFunction or "non-fatal assertion failed";
		if type(msgStringOrFunction) == 'string' and select('#', ...) > 0 then
			error = msgStringOrFunction:format(...);
		elseif type(msgStringOrFunction) == 'function' then
			error = msgStringOrFunction(...);
		end

		SetErrorCallstackHeight(GetCallstackHeight() - 1); -- report error from the previous function
		if HandleLuaError then
			HandleLuaError(error);
		elseif ProcessExceptionClient then
			ProcessExceptionClient(error);
		end
		SetErrorCallstackHeight(nil);
	end
end
