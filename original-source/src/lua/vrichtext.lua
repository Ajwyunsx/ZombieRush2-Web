VRichText = VClass("RichText", VNode);

function VRichText:onCreate(attr)
    return ccui.RichText:create();
end

function VRichText:InsertElementImage(tag, color, opacity, image, pos)
    local img = ccui.RichElementImage:create(tag, color, opacity, image);
    if pos then
    	self:insertElement(img, pos);
    else
    	self:pushBackElement(img);
    end
end

function VRichText:InsertElementText(tag, color, opacity, text, fontName, fontSize, pos)
	if not fontName then
		fontName = "Arial";
	end
	if not fontSize then
		fontSize = 25;
	end
	local txt = ccui.RichElementText:create(tag, color, opacity, text, fontName, fontSize);
	if pos then
    	self:insertElement(txt, pos);
    else
    	self:pushBackElement(txt);
    end
end