# Hanabie Plasma Theme

A KDE Plasma 6 rice theme for Arch Linux inspired by the band [HANABIE.](https://hanabie.jp/)

Dark aesthetic with hot pink and deep red accents based on the band's visual identity.

---

## What's Included

| Component | Details |
|---|---|
| **Look and Feel** | KDE Plasma 6 LnF package (`org.ookami.hanabie`) |
| **Color Scheme** | HanabieColors — dark greys, hot pink (`#ff80e0`), deep red (`#8c1011`) |
| **Plasma Shell Theme** | Hanabie — panel and widgets styled with the color scheme |
| **Window Decoration** | Hanabie Aurorae — dark titlebars with pink active border |
| **Icon Theme** | HanabieNeonIcons — custom icons with Papirus-Dark fallback |
| **Splash Screen** | BeautifulTreeAnimation (by creativity, LGPLv3) |
| **Lock Screen** | Custom QML with band wallpaper, pink accents, and auth |
| **SDDM Theme** | Eucalyptus Drop 2.0.0 (by Matt Jolly) with HANABIE wallpaper and pink accent |
| **Wallpapers** | `hanabie-galaxy.jpg` (desktop), `hanabie-group-pic.jpg` (lock screen) |

---

## Installation

```bash
git clone https://github.com/edbasurto/ookami-hanabie-plasma-theme.git
cd ookami-hanabie-plasma-theme
sudo ./install.sh
```

The script will:
- Install any missing dependencies (`plasma-desktop`, `sddm`, `kpackage`, `papirus-icon-theme`, `kvantum`, `noto-fonts`)
- Install all theme components system-wide under `/usr/share/`
- Configure SDDM to use the eucalyptus-drop theme
- Attempt to auto-apply the Look-and-Feel via `plasma-apply-lookandfeel`

---

## Post-Install Configuration

A few things that need to be set manually in System Settings after installing:

### Window Decoration
**System Settings → Appearance → Window Decorations**
Select **Hanabie** from the list.

### Active Window Glow
**System Settings → Workspace → Desktop Effects**
Enable **Window Outline** and set the color to `#ff80e0`.

### Kvantum (app styling)
The theme uses Kvantum for Qt application chrome. After installing:
1. Open **Kvantum Manager**
2. Select a dark Kvantum theme (e.g. `KvDark` or `KvCurves`)
3. Click **Use this theme**

### Apply changes
If the theme wasn't applied automatically, run:
```bash
plasma-apply-lookandfeel -a org.ookami.hanabie
```

Or go to **System Settings → Appearance → Global Theme** and select **Hanabie**.

Restart Plasma to make sure everything takes effect:
```bash
kquitapp6 plasmashell && kstart plasmashell
```

---

## Uninstall

```bash
sudo rm -rf \
    /usr/share/plasma/look-and-feel/org.ookami.hanabie \
    /usr/share/plasma/look-and-feel/BeautifulTreeAnimation \
    /usr/share/plasma/desktoptheme/Hanabie \
    /usr/share/aurorae/themes/Hanabie \
    /usr/share/icons/HanabieNeonIcons \
    /usr/share/color-schemes/HanabieColors.colors \
    /usr/share/wallpapers/hanabie \
    /usr/share/sddm/themes/eucalyptus-drop \
    /etc/sddm.conf.d/hanabie-theme.conf
```

---

## Credits

- **BeautifulTreeAnimation** splash screen — by *creativity* (LGPLv3)
- **Eucalyptus Drop** SDDM theme — by [Matt Jolly](https://gitlab.com/Matt.Jolly/sddm-eucalyptus-drop) (GPL-3.0)
- Theme author: **Ookami**
- Inspired by [HANABIE.](https://hanabie.jp/)
