// GUI_Extension: 本 mod 所有悬停体共用的开关逻辑。
// Create 里设置 msl_hoverKey（MODS 勾选项对应的全局名），关掉时退出交互列表。
var _msl_on = 1

if (variable_global_exists(msl_hoverKey))
    _msl_on = variable_global_get(msl_hoverKey)

if (_msl_on)
{
    scr_guiInteractiveEventUpdate(id, 0)
}
else
{
    // 已经弹出的提示先收掉，再把交互事件注销（-4，scr_hoverDestroy 对 -4 是空操作）
    hoverID = scr_hoverDestroy(hoverID)
    scr_guiInteractiveEventUpdate(id, -4)
}
