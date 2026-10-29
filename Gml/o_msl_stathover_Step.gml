// GUI_Extension: 斗志/神智的悬停区共用这段 Step。
// 开关关掉时生命条恢复成整条 158px，这两个悬停区必须退出交互列表，
// 否则会盖在生命条右半边弹出斗志/神智说明。
if (variable_global_exists("msl_gui_ext_show_psy") && global.msl_gui_ext_show_psy)
{
    scr_guiInteractiveEventUpdate(id, 0)
}
else
{
    // 已经弹出的提示先收掉，再把交互事件注销（-4，scr_hoverDestroy 对 -4 是空操作）
    hoverID = scr_hoverDestroy(hoverID)
    scr_guiInteractiveEventUpdate(id, -4)
}
