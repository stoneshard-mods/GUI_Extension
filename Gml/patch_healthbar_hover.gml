// GUI_Extension: 生命悬停的命中区/高亮跟着「神智斗志」开关走。
//   开：生命只剩左 60%，命中区和高亮缩到这一段（右边让给斗志/神智）
//   关：换回原版整套（覆盖整个 158px 槽位），不用重开 UI
// 这段既挂在 Create 末尾（创建当帧就正确），也挂在 Step（设置里改完立刻生效）。
if (variable_global_exists("msl_gui_ext_show_psy") && global.msl_gui_ext_show_psy)
{
    sprite_index = s_msl_hpmask
    spriteHover = s_msl_hphover
}
else
{
    sprite_index = s_healthbar_mask
    spriteHover = s_healthbar_hover
}
