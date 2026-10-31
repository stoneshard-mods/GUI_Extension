using ModShardLauncher;
using ModShardLauncher.Mods;
using UndertaleModLib.Models;

namespace GUI_Extension;

public class GUIExtensionMod : Mod
{
    public override string Name => "GUI_Extension";
    public override string Author => "Pixel32E-QQ:3566723459";
    public override string Description => "底部 HUD 重制：斗志/神智做成面板两端的圆柱液体容器（可悬停看属性），生命改回整条横条，精力与格挡力量各占右槽一半，右下角显示日期时间，敌人头顶可选血条；设置项支持中/英/俄/日/韩";
    public override string ShortDesc => "Morale/Sanity cylinders, HP bar, Energy & Block split 50/50, clock, optional enemy HP bar (multi-language UI)";
    public override string Version => "v1.17.2.0";

    // scr_healbar 里两段绘制代码（生命块 + 精力块）的起止锚点。
    // 游戏改代码时这里抛异常，而不是静默画出错位的东西。
    private const string HealbarCode = "gml_GlobalScript_scr_healbar";
    private const string HealbarStart = "if (_thresholdWidth < _healthBarWidth)";
    private const string HealbarEnd = "string(_MP) + \"/\" + string(_maxMP)";

    private const string BottomPanelCode = "gml_Object_o_bottompanel_Create_0";
    private const string BottomPanelDrawCode = "gml_Object_o_bottompanel_Draw_0";
    private const string EnemyDrawEndCode = "gml_Object_o_enemy_Draw_73";
    private const string CheckboxDrawCode = "gml_Object_o_checkbox_Draw_0";
    private const string EnergyHoverCode = "gml_Object_o_gui_energybarHover_Create_0";
    private const string EnergyHoverObject = "o_gui_energybarHover";
    private const string HealthHoverCode = "gml_Object_o_gui_healthbarHover_Create_0";

    // 反编译器有时把资源写成对象名、有时写成数字 id，两种都认。
    private static readonly string[] EnergyHoverAnchors =
    {
        "scr_guiCreateInteractive(id, o_gui_energybarHover,",
        "scr_guiCreateInteractive(id, 4738,",
    };

    private static readonly string[] HealthHoverAnchors =
    {
        "scr_guiCreateInteractive(id, o_gui_healthbarHover,",
        "scr_guiCreateInteractive(id, 4737,",
    };

    public override void PatchMod()
    {
        ReplaceBars();
        AddBlockBarHover();
        AddStatHovers();
        AddClock();
        AddEnemyHp();
        AddMenuLocalization();
        AddSettingsMenu();
    }

    private void AddMenuLocalization()
    {
        // 设置项多语言：启动器的 UIComponent 只收静态字符串，
        // 所以设置项名字统一用英文原文当键，勾选项画之前调 scr_msl_gui_ext_tr 翻一次。
        Msl.AddFunction(Code("scr_msl_gui_ext_tr.gml"), "scr_msl_gui_ext_tr");
        InsertAbove(CheckboxDrawCode, "draw_sprite(checkboxSprite", Code("patch_checkbox_tr.gml"), "勾选项文本本地化");
    }

    private void AddClock()
    {
        // 右下角时间：追加在底部面板的 Draw 末尾（HUD 隐藏时一起消失）。
        InsertAtEnd(BottomPanelDrawCode, Code("patch_bottompanel_clock.gml"), "右下角时间显示");
    }

    private void AddEnemyHp()
    {
        // 敌人头顶血条：追加在 o_enemy 的 Draw End 末尾。
        // o_enemy 的子对象都没有重写 Draw_73，所以这一处覆盖所有敌人。
        InsertAtEnd(EnemyDrawEndCode, Code("patch_enemyhp.gml"), "敌人头顶血条");
    }

    private void AddSettingsMenu()
    {
        // 启动器把它渲染成「MODS」页里的一个勾选项：状态存进 msl_menu_mod.ini 的 [GUI_Extension] 段，
        // 开局由 o_msl_initializer 读回 global.msl_gui_ext_*。
        // 名字一律写英文原文 —— scr_msl_gui_ext_tr 用它当键，
        // 勾选项绘制时按 global.language 翻成中文/俄文/日文/韩文（其它语言回退英文）。
        Msl.AddMenu(
            "GUI_Extension",
            new UIComponent(
                "Show chance on bar",
                "msl_gui_ext_prr_on_bar",
                UIComponentType.CheckBox,
                0),
            new UIComponent(
                "Show sanity & morale",
                "msl_gui_ext_show_psy",
                UIComponentType.CheckBox,
                1),
            new UIComponent(
                "Show block power bar",
                "msl_gui_ext_show_bp",
                UIComponentType.CheckBox,
                1),
            new UIComponent(
                "Show clock",
                "msl_gui_ext_show_clock",
                UIComponentType.CheckBox,
                1),
            new UIComponent(
                "Always show enemy HP",
                "msl_gui_ext_enemyhp_always",
                UIComponentType.CheckBox,
                0));
    }

    private void ReplaceBars()
    {
        // 只替换两条槽位的绘制代码：sec_hp / sec_mp 的 lerp、阈值计算都保持原版。
        try
        {
            Msl.LoadGML(HealbarCode)
                .MatchFromUntil(HealbarStart, HealbarEnd)
                .ReplaceBy(ModFiles.GetCode("patch_healbar.gml"))
                .Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "GUI_Extension 打补丁失败：替换底部条绘制代码（" + HealbarCode + "）。游戏代码可能已更新。", ex);
        }
    }

    private void AddBlockBarHover()
    {
        // 提示内容：复用 o_hoverCharEnergy 的排版/绘制，只换掉数据来源（User 10 事件）。
        Msl.AddObject("o_msl_blockpower", spriteName: "", parentName: "o_hoverCharEnergy",
            isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent("o_msl_blockpower", Code("o_msl_blockpower_Other_20.gml"), EventType.Other, 20);

        // 交互体：格挡条只占右槽右半（83px），命中区/高亮按半宽那套。
        AddHoverObject("o_msl_blockhover", "s_msl_blockmask", "s_msl_blockhover",
            "o_msl_blockpower", "msl_gui_ext_show_bp");

        // 在底部面板里挂上格挡条的悬停区（x = 条起点 - 2）。
        InsertBelow(BottomPanelCode, EnergyHoverAnchors, Code("patch_bottompanel_hover.gml"), "创建格挡条悬停区");
    }

    private void AddStatHovers()
    {
        // 生命 / 精力的提示内容：挂到原版那两块悬停区上（命中区/位置保持原版，只换内容），
        // 因为条上不印上限，提示里要带「当前/有效上限 + 伤势・疲劳扣了多少」。
        AddInfoObject("o_msl_hpinfo", "o_msl_hpinfo_Other_20.gml", "o_hoverCharHealth");
        AddInfoObject("o_msl_mpinfo", "o_msl_mpinfo_Other_20.gml", "o_hoverCharEnergy");

        // 原生命悬停区：位置本来就是整条左槽，把提示内容换成上限版。
        InsertAtEnd(HealthHoverCode, Code("patch_healthbar_hover.gml"), "生命提示改挂上限版内容");

        // 原精力悬停区：格挡条开着时缩到右槽左半，关掉时恢复原版整套。
        InsertAtEnd(EnergyHoverCode, Code("patch_energybar_hover.gml"), "精力悬停区缩到左半");
        Msl.AddNewEvent(EnergyHoverObject, Code("patch_energybar_hover.gml"), EventType.Step, 0);

        // 斗志 / 神智：改成面板两端的柱状容器，悬停区跟着挪到容器上。
        AddStatHover("o_msl_moraleinfo", "o_msl_moraleinfo_Other_20.gml",
            "o_msl_moralehover", "s_msl_moraltubemask", "s_msl_moraltubehover", "msl_gui_ext_show_psy");
        AddStatHover("o_msl_sanityinfo", "o_msl_sanityinfo_Other_20.gml",
            "o_msl_sanityhover", "s_msl_sanitytubemask", "s_msl_sanitytubehover", "msl_gui_ext_show_psy");

        // 在底部面板里挂上两根容器的悬停区。
        InsertBelow(BottomPanelCode, HealthHoverAnchors, Code("patch_bottompanel_stat_hover.gml"), "创建斗志/神智容器悬停区");
    }

    private void AddInfoObject(string infoName, string infoGml, string parentName)
    {
        // 提示内容对象：父对象负责排版/绘制，User 10 里换成自己的数据与文字。
        Msl.AddObject(infoName, spriteName: "", parentName: parentName,
            isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent(infoName, Code(infoGml), EventType.Other, 20);
    }

    private void AddStatHover(string infoName, string infoGml, string hoverName, string maskSprite, string highlightSprite, string key, string parentName = "o_hoverCharEnergy")
    {
        // 提示内容：复用原版提示对象的排版/绘制，只覆盖 User 10（数据来源与文字）。
        Msl.AddObject(infoName, spriteName: "", parentName: parentName,
            isVisible: true, isPersistent: false, isAwake: true);
        Msl.AddNewEvent(infoName, Code(infoGml), EventType.Other, 20);

        AddHoverObject(hoverName, maskSprite, highlightSprite, infoName, key);
    }

    private void AddHoverObject(string hoverName, string maskSprite, string highlightSprite, string contentObject, string key)
    {
        // 交互体：复用 o_gui_barHover 的悬停逻辑，命中区/高亮用自己那一套。
        // msl_hoverKey 供共用的 Step 判断该不该挂进交互列表。
        Msl.AddObject(hoverName, spriteName: maskSprite, parentName: "o_gui_barHover",
            isVisible: true, isPersistent: true, isAwake: true);
        Msl.AddNewEvent(hoverName,
            "event_inherited()\nspriteHover = " + highlightSprite + "\nhoverObject = " + contentObject
            + "\nmsl_hoverKey = \"" + key + "\"\n",
            EventType.Create, 0);
        Msl.AddNewEvent(hoverName, Code("o_msl_hover_Step.gml"), EventType.Step, 0);
    }

    private string Code(string fileName)
    {
        return ModFiles.GetCode(fileName);
    }

    private static void InsertBelow(string codeName, string[] anchors, string code, string what)
    {
        System.Exception last = null;

        foreach (string anchor in anchors)
        {
            try
            {
                Msl.LoadGML(codeName).MatchFrom(anchor).InsertBelow(code).Save();
                return;
            }
            catch (System.Exception ex)
            {
                last = ex;
            }
        }

        throw new System.InvalidOperationException(
            "GUI_Extension 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", last);
    }

    private static void InsertAbove(string codeName, string anchor, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchFrom(anchor).InsertAbove(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "GUI_Extension 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }

    private static void InsertAtEnd(string codeName, string code, string what)
    {
        try
        {
            Msl.LoadGML(codeName).MatchAll().InsertBelow(code).Save();
        }
        catch (System.Exception ex)
        {
            throw new System.InvalidOperationException(
                "GUI_Extension 打补丁失败：" + what + "（" + codeName + "）。游戏代码可能已更新。", ex);
        }
    }
}
