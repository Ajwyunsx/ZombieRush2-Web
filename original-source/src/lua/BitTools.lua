-- BitTools.lua
BitTools = vclass("BitTools");

function BitTools:initialize( )
	self.is64 = false;
	if gRes:Platform() == "ios" or gRes:Platform() == "mac" then
		self.is64 = true;
	end

	if self.is64 then
		require("bit64");
		self.bit = bit;
	else
		self.bit = require("bit");
	end
end

function BitTools:_or( a, b )
	if self.is64 then
		return self.bit:_or(a,b);
	else
		return self.bit.bor(a,b);
	end
end

function BitTools:_and( a, b )
	if self.is64 then
		return self.bit:_and(a,b);
	else
		return self.bit.band(a,b);
	end
end

function BitTools:_rshift( a, b )
	if self.is64 then
		return self.bit:_rshift(a,b);
	else
		return self.bit.rshift(a,b);
	end
end

function BitTools:_lshift( a, b )
	if self.is64 then
		return self.bit:_lshift(a,b);
	else
		return self.bit.lshift(a,b);
	end
end

