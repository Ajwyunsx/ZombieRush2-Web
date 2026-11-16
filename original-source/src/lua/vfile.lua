--vfile.lua

VFile = VClass("File", VNode)

function VFile:new(attr)
    local node = VNode(attr.fileName);
    local iter = VDataIter()
    while attr:Travel(iter) do
        if iter:Name() ~= "class" then
            node[iter:Name()] = iter:Data();
        end
    end
    return node;
end