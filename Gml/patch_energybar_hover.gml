// GUI_Extension: 格挡条铺满右槽之后，原精力条已经不在槽位里了（精力挪到右边的容器），
// 所以这块悬停区要退出交互列表；关掉格挡条时恢复原版整套（整个 167px 槽位）。
// 这段既挂在 Create 末尾，也挂在 Step（设置里改完立刻生效）。
if (variable_global_exists("msl_gui_ext_show_bp") && global.msl_gui_ext_show_bp)
{
    hoverID = scr_hoverDestroy(hoverID)
    scr_guiInteractiveEventUpdate(id, -4)
}
else
{
    sprite_index = s_energybar_mask
    spriteHover = s_energybar_hover
    scr_guiInteractiveEventUpdate(id, 0)
}
