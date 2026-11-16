-- veditor.lua

_VEditorReturnType = VEnum{
    Default = 0,
    Done = 1,
    Send = 2,
    Search = 3,
    Go = 4,
}

_VEditorInputMode = VEnum{
    Any = 0,
    Email = 1,
    Number = 2,
    Phone = 3,
    Url = 4,
    Decimal = 5,
    SingleLine = 6,
}

_VEditorInputFlag = VEnum{
	Password = 0,
	Sensitive = 1,
	InitialCapsWord = 2,
	InitialCapsSentence = 3,
	InitialCapsAll = 4,
}

VEditor = VClass("Editor", VNode)

function VEditor:onCreate(attr)
	if not attr.bgImage then attr.bgImage = "shurukuang.png" end;
	if not attr.size then attr.size = Var{300,100} end;
	local sprite = cc.Scale9Sprite:create();
	
	local pFrame = gRes:SpriteFrame(attr.bgImage);
	local batchNode = nil;
	if pFrame then
		batchNode = cc.SpriteBatchNode:createWithTexture(pFrame:getTexture(), 9);
		sprite:updateWithBatchNode(batchNode, pFrame:getRect(), pFrame:isRotated(), cc.rectZero());
	else
		if gRes:checkImageExist(attr.bgImage) then
			batchNode = cc.SpriteBatchNode:create(attr.bgImage, 9);
			sprite:updateWithBatchNode(batchNode, cc.rectZero(), false, cc.rectZero());
		end
	end
	if attr.capInset then 
		sprite:setCapInsets(cc.rect(attr.capInset.x, attr.capInset.y, attr.capInset.width, attr.capInset.height))
	end
    return cc.EditBox:create(attr.size, sprite);
end

function VEditor:Init(attr)
	VNode.Init(self, attr);
	if not attr.returnType then self.returnType = _VEditorReturnType.Done end;
	if not attr.inputMode then self.inputMode = _VEditorInputMode.SingleLine end;
	self:setPlaceholderFont("Arial", 15);
	self:registerScriptEditBoxHandler(_editorStatusChange)
end

function _editorStatusChange(eventType, editor)
	self = VNode(editor);
	if eventType == "began" then
		if self.delegate and self.delegate.editorDidBegin then
			return self.delegate:editorDidBegin(self);
		end
        -- triggered when an edit box gains focus after keyboard is shown
    elseif eventType == "ended" then
    	if self.delegate and self.delegate.editorDidEnded then
			return self.delegate:editorDidEnded(self);
		end
        -- triggered when an edit box loses focus after keyboard is hidden.
    elseif eventType == "changed" then
    	if self.delegate and self.delegate.editorDidChanged then
			return self.delegate:editorDidChanged(self);
		end
        -- triggered when the edit box text was changed.
    elseif eventType == "return" then
    	if self.delegate and self.delegate.editorDidReturn then
			return self.delegate:editorDidReturn(self);
		end
        -- triggered when the return button was pressed or the outside area of keyboard was touched.
    end
end

function VEditor:on_align(alignment)
	self:setAlignment(_VTextAlign(alignment));
end

function VEditor:on_text(text)
    self:setText(text);
end

function VEditor:on_font(font)
	self:setFontName(font);
end

function VEditor:on_fontSize(size)
	self:setFontSize(size);
end

function VEditor:on_fontColor(color)
	self:setFontColor(color);
end

function VEditor:on_placeHolder(placeHolder)
	self:setPlaceHolder(placeHolder);
end

function VEditor:on_pFont(font)
	self:setPlaceholderFontName(font);
end

function VEditor:on_pFontSize(size)
	self:setPlaceholderFontSize(size);
end

function VEditor:on_pFontColor(color)
	self:setPlaceholderFontColor(color);
end

function VEditor:on_inputMode(mode)
	self:setInputMode(_VEditorInputMode(mode));
end

function VEditor:on_inputFlag(flag)
	self:setInputFlag(_VEditorInputFlag(flag));
end

function VEditor:on_maxLength(max)
	self:setMaxLength(max);
end

function VEditor:on_returnType(type)
	self:setReturnType(_VEditorReturnType(type))
end