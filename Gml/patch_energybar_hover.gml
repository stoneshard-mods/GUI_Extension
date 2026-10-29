// GUI_Extension: 精力悬停的命中区/高亮跟着「格挡条」开关走。
//   开：精力只剩左半，命中区和高亮缩到左半（右边让给格挡力量）
//   关：换回原版整套（覆盖整个 167px 槽位），不用重开 UI
// 这段既挂在 Create 末尾（创建当帧就正确），也挂在 Step（设置里改完立刻生效）。
if (variable_global_exists("msl_gui_ext_show_bp") && global.msl_gui_ext_show_bp)
{
    sprite_index = s_msl_energymask
    spriteHover = s_msl_energyhover
}
else
{
    sprite_index = s_energybar_mask
    spriteHover = s_energybar_hover
}
