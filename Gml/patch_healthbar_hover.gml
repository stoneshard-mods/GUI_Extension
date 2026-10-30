// GUI_Extension: 生命改成容器之后，槽位整段让给斗志 / 神智，生命提示挂在容器上
// （o_msl_hptubehover），所以「神智斗志」开着时这块原生命悬停区要退出交互列表。
// 关掉时恢复原版整套：命中区覆盖整个 158px 槽位、高亮用原版精灵。
// 这段既挂在 Create 末尾（创建当帧就正确），也挂在 Step（设置里改完立刻生效）。
if (variable_global_exists("msl_gui_ext_show_psy") && global.msl_gui_ext_show_psy)
{
    hoverID = scr_hoverDestroy(hoverID)
    scr_guiInteractiveEventUpdate(id, -4)
}
else
{
    sprite_index = s_healthbar_mask
    spriteHover = s_healthbar_hover
    scr_guiInteractiveEventUpdate(id, 0)
}
