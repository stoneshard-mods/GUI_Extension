// GUI_Extension: 右槽改成「精力 50% + 格挡力量 50%」之后，原精力条只剩左半。
// 开着格挡条时：命中区/高亮缩到半宽（83px），提示内容换成带疲劳上限的 o_msl_mpinfo。
// 关掉格挡条时：恢复原版整套（整个 167px 槽位 + 原版内容）。
// 这段既挂在 Create 末尾（创建当帧就正确），也挂在 Step（设置里改完立刻生效）。
if (!variable_instance_exists(id, "msl_mpHoverOrig"))
    msl_mpHoverOrig = hoverObject

if (variable_global_exists("msl_gui_ext_show_bp") && global.msl_gui_ext_show_bp)
{
    sprite_index = s_msl_mpbar_mask
    spriteHover = s_msl_mpbar_hover
    hoverObject = o_msl_mpinfo
    scr_guiInteractiveEventUpdate(id, 0)
}
else
{
    sprite_index = s_energybar_mask
    spriteHover = s_energybar_hover
    hoverObject = msl_mpHoverOrig
    scr_guiInteractiveEventUpdate(id, 0)
}
