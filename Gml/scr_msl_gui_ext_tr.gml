// GUI_Extension: MODS 设置项文本本地化。
// 启动器的 UIComponent 只收一个静态字符串，所以这里用「英文原文当键」，
// 由 o_checkbox 的 Draw 在绘制前调用本函数翻译；匹配不到就原样返回。
//
// 注意：参数必须用 argument0 取，不能写 arg0 —— 注入代码重新编译时
// arg0 会被解析成实例变量 self.arg0（不是函数参数），运行时报
// "arg0 not set before reading it"。
//
// 游戏语言编号（见 o_languagesStressTester_Create_0 的 langArray）：
//   1 Русский / 2 English / 3 中文 / 4 Deutsch / 5 Español / 6 Français
//   7 Italiano / 8 Português / 9 Polski / 10 Türkçe / 11 日本語 / 12 한국어
// 目前提供 RU / EN / CH / JP / KR，其余语言回退英文。
function scr_msl_gui_ext_tr()
{
    var _msl_key = argument0;
    var _msl_lang = global.language;

    if (_msl_lang == 2)
        return _msl_key;

    switch (_msl_lang)
    {
        case 1:
            if (_msl_key == "Show chance on bar") return "Показывать шанс блока";
            if (_msl_key == "Show sanity & morale") return "Показывать рассудок и боевой дух";
            if (_msl_key == "Show block power bar") return "Показывать шкалу блока";
            if (_msl_key == "Show clock") return "Показывать время";
            if (_msl_key == "Always show enemy HP") return "Всегда показывать здоровье врагов";
            break;

        case 3:
            if (_msl_key == "Show chance on bar") return "格挡条显示几率";
            if (_msl_key == "Show sanity & morale") return "显示神智斗志";
            if (_msl_key == "Show block power bar") return "显示格挡条";
            if (_msl_key == "Show clock") return "显示时间";
            if (_msl_key == "Always show enemy HP") return "敌人血条常显";
            break;

        case 11:
            if (_msl_key == "Show chance on bar") return "ブロック率を表示";
            if (_msl_key == "Show sanity & morale") return "正気と士気を表示";
            if (_msl_key == "Show block power bar") return "ブロック値バーを表示";
            if (_msl_key == "Show clock") return "時刻を表示";
            if (_msl_key == "Always show enemy HP") return "敵の体力を常時表示";
            break;

        case 12:
            if (_msl_key == "Show chance on bar") return "방어율 표시";
            if (_msl_key == "Show sanity & morale") return "정신력·사기 표시";
            if (_msl_key == "Show block power bar") return "방어력 바 표시";
            if (_msl_key == "Show clock") return "시간 표시";
            if (_msl_key == "Always show enemy HP") return "적 체력 상시 표시";
            break;
    }

    return _msl_key;
}
