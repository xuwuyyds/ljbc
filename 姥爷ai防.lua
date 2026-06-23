-- 反作弊绕过 + 保存到列表
so=gg.getRangesList('libtersafe.so')[1].start
gg.setValues({
{address=so+0x99140,flags=4,value=10083,freeze=true},
})
local lib = gg.getRangesList("libtersafe.so")
if lib == nil or #lib == 0 then
    print("找不到 libtersafe.so")
    return
end

local base = lib[1].start
local ret = 0xD65F03C0
local nop = 0x1F2003D5

-- 要修改的函数
local funcs = {
    {0x55F070, "防闪1"},
    {0x55F0F8, "防闪2"},
    {0x563C28, "防闪3"},
    {0x4C6A84, "report_error"},
    {0x2D0E84, "SendCmd"},
    {0x1CE0FC, "GetReportData"},
    {0x1CE668, "DelReportData"},
    {0x1D0094, "GetReportData2"},
    {0x1D0100, "GetReportData3"},
    {0x1D055C, "GetReportData4"},
    {0x1D016C, "DelReportData3"},
    {0x1D0B14, "DelReportData4"},
    {0x1C4A08, "get_report_data3"},
    {0x1C535C, "get_report_data4"},
    {0x1B8CE8, "del_report_data"},
    {0x1B9570, "get_report_data"},
    {0x1BEBC8, "get_report_data2"},
}

local saved = {}
local vals = {}

for _, f in ipairs(funcs) do
    local off = f[1]
    local name = f[2]
    local addr = base + off
    
    -- 写入 RET 和 NOP
    table.insert(vals, {address = addr, flags = gg.TYPE_DWORD, value = ret})
    table.insert(saved, {address = addr, flags = gg.TYPE_DWORD, value = ret, name = name .. "_ret"})
    
    for i = 1, 3 do
        local patchAddr = addr + i*4
        table.insert(vals, {address = patchAddr, flags = gg.TYPE_DWORD, value = nop})
        table.insert(saved, {address = patchAddr, flags = gg.TYPE_DWORD, value = nop, name = name .. "_nop" .. i})
    end
end

-- 执行修改
gg.setValues(vals)

-- 保存到GG保存列表
gg.addListItems(saved)

print("✓ 修改完成! 已保存 " .. #saved .. " 个地址到保存列表")