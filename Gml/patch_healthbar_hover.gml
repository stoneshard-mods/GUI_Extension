// GUI_Extension: 生命条现在是原版整条横条（占满左槽），
// 所以原版这块悬停区保持原位置/原命中区不动，只把提示内容换成
// o_msl_hpinfo（带「当前/有效上限 + 伤势扣减」）。
// 这段挂在 Create 末尾，执行时 hoverObject 还是原版值，这里直接覆盖。
hoverObject = o_msl_hpinfo
scr_guiInteractiveEventUpdate(id, 0)
