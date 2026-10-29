// GUI_Extension: 格挡条的悬停区。
// 开关关掉后精力条恢复成整条 167px，这个悬停区必须退出交互列表，
// 否则会盖在精力条右半边弹出格挡力量说明。
if (variable_global_exists("msl_gui_ext_show_bp") && global.msl_gui_ext_show_bp)
{
    scr_guiInteractiveEventUpdate(id, 0)
}
else
{
    // 已经弹出的提示先收掉，再把交互事件注销（-4，scr_hoverDestroy 对 -4 是空操作）
    hoverID = scr_hoverDestroy(hoverID)
    scr_guiInteractiveEventUpdate(id, -4)
}
