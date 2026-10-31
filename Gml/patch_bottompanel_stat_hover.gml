// GUI_Extension: 斗志 / 神智 两根柱状容器的悬停区。
// 规则和原版一致：交互体位置 = 元件左上 - 2；两根容器贴底，y 按面板高度现算。
// 面板内 x：斗志 138（左端）、神智 498（右端），宽 22。
var _msl_tubeHoverY = sprite_height - 46 - 2
scr_guiCreateInteractive(id, o_msl_moralehover, depth - 1, 136, _msl_tubeHoverY)
scr_guiCreateInteractive(id, o_msl_sanityhover, depth - 1, 496, _msl_tubeHoverY)
