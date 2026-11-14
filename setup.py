import os, re, math, shutil, base64
from PIL import Image, ImageDraw

# ---------- Logo ----------
import math
from PIL import Image, ImageDraw, ImageFilter, ImageOps

def vgrad(S, top, bottom):
    g = Image.linear_gradient('L').resize((S, S))          # black top -> white bottom
    return ImageOps.colorize(g, top, bottom).convert('RGBA')

def rgrad(S, center, edge):
    g = Image.radial_gradient('L').resize((S, S))          # black center -> white edge
    return ImageOps.colorize(g, center, edge).convert('RGBA')

def star8(cx, cy, r):
    pts = []
    for i in range(16):
        rr = r if i % 2 == 0 else r * 0.76
        a = math.pi / 8 * i - math.pi / 2
        pts.append((cx + rr * math.cos(a), cy + rr * math.sin(a)))
    return pts

def art(size, k, bg):
    S = size * 2
    P = lambda x, y: ((0.5 + (x - 0.5) * k) * S, (0.5 + (y - 0.5) * k) * S)
    R = lambda r: r * k * S
    img = rgrad(S, (22, 120, 92), (5, 36, 27)) if bg else Image.new('RGBA', (S, S), (0, 0, 0, 0))

    if bg:  # faint islamic geometry
        pat = Image.new('RGBA', (S, S), (0, 0, 0, 0))
        d = ImageDraw.Draw(pat)
        cx, cy = P(.5, .5)
        for rr, a in [(.47, 60), (.40, 45)]:
            d.ellipse([cx - R(rr), cy - R(rr), cx + R(rr), cy + R(rr)], outline=(212, 175, 55, a), width=3)
        for rot in (0, 45):
            pts = []
            for i in range(4):
                a = math.radians(rot + 45 + 90 * i)
                pts.append((cx + R(.45) * math.cos(a), cy + R(.45) * math.sin(a)))
            d.line(pts + [pts[0]], fill=(212, 175, 55, 80), width=3)
        img = Image.alpha_composite(img, pat)

    gold = vgrad(S, (250, 230, 130), (190, 140, 30))

    # --- crescent (+ glow) ---
    m = Image.new('L', (S, S), 0)
    md = ImageDraw.Draw(m)
    def circ(cx, cy, r, f):
        x, y = P(cx, cy); rr = R(r)
        md.ellipse([x - rr, y - rr, x + rr, y + rr], fill=f)
    circ(.5, .34, .22, 255)
    circ(.585, .295, .185, 0)
    glow = m.filter(ImageFilter.GaussianBlur(S * 0.02)).point(lambda v: int(v * 0.55))
    img.paste(Image.new('RGBA', (S, S), (255, 215, 90, 255)), (0, 0), glow)
    img.paste(gold, (0, 0), m)

    # --- star ---
    sm = Image.new('L', (S, S), 0)
    sd = ImageDraw.Draw(sm)
    sx, sy = P(.605, .285)
    pts = []
    for i in range(10):
        r = R(.05) if i % 2 == 0 else R(.02)
        a = -math.pi / 2 + i * math.pi / 5
        pts.append((sx + r * math.cos(a), sy + r * math.sin(a)))
    sd.polygon(pts, fill=255)
    img.paste(gold, (0, 0), sm)

    # --- mosque silhouette ---
    mm = Image.new('L', (S, S), 0)
    d = ImageDraw.Draw(mm)
    def rect(x0, y0, x1, y1, f=255):
        a, b = P(x0, y0); c, e = P(x1, y1)
        d.rectangle([a, b, c, e], fill=f)
    def ell(cx, cy, rx, ry, f=255):
        x, y = P(cx, cy)
        d.ellipse([x - R(rx), y - R(ry), x + R(rx), y + R(ry)], fill=f)
    def poly(pts, f=255):
        d.polygon([P(*p) for p in pts], fill=f)
    base = .88
    rect(.33, .75, .67, base)               # main hall
    ell(.5, .75, .17, .14)                  # central dome
    rect(.497, .56, .503, .62)              # finial pole
    ell(.5, .555, .012, .012)               # finial ball
    for cx in (.255, .745):                 # minarets
        rect(cx - .022, .56, cx + .022, base)
        rect(cx - .034, .60, cx + .034, .625)   # balcony
        poly([(cx - .026, .56), (cx + .026, .56), (cx, .49)])  # cone
        ell(cx, .485, .008, .008)
    for cx in (.385, .615):                 # small side domes
        ell(cx, .75, .055, .05)
    rect(.28, .81, .33, base); rect(.67, .81, .72, base)  # side wings
    # door and windows (cut out)
    rect(.47, .80, .53, base + .01, 0); ell(.5, .80, .03, .03, 0)
    for cx in (.40, .60):
        rect(cx - .015, .78, cx + .015, .84, 0); ell(cx, .78, .015, .015, 0)
    rect(.30, base, .70, base + .01)
    img.paste(vgrad(S, (245, 215, 110), (170, 120, 25)), (0, 0), mm)
    return img.resize((size, size), Image.LANCZOS)


os.makedirs('assets', exist_ok=True)
art(1024, 1.0, True).save('assets/icon.png')
art(1024, 0.62, False).save('assets/icon_fg.png')
art(512, 1.0, True).save('assets/logo.png')

# ---------- Manifest ----------
mf = 'android/app/src/main/AndroidManifest.xml'
s = open(mf, encoding='utf8').read()
perms = ''.join('<uses-permission android:name="android.permission.%s"/>\n' % p for p in [
    'ACCESS_FINE_LOCATION', 'ACCESS_COARSE_LOCATION', 'POST_NOTIFICATIONS', 'SCHEDULE_EXACT_ALARM',
    'USE_EXACT_ALARM', 'RECEIVE_BOOT_COMPLETED', 'VIBRATE', 'WAKE_LOCK', 'INTERNET', 'ACCESS_NETWORK_STATE'])
s = re.sub(r'(<manifest[^>]*>)', lambda m: m.group(1) + '\n' + perms, s, count=1)
recv = '''
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ActionBroadcastReceiver"/>
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
<intent-filter>
<action android:name="android.intent.action.BOOT_COMPLETED"/>
<action android:name="android.intent.action.MY_PACKAGE_REPLACED"/>
<action android:name="android.intent.action.QUICKBOOT_POWERON"/>
<action android:name="com.htc.intent.action.QUICKBOOT_POWERON"/>
</intent-filter>
</receiver>
'''
s = s.replace('</application>', recv + '</application>', 1)
s = s.replace('<application', '<queries><intent><action android:name="android.intent.action.VIEW"/><data android:scheme="https"/></intent></queries>\n<application', 1)
s = re.sub(r'android:label="[^"]*"', 'android:label="নূরনামা"', s, count=1)
open(mf, 'w', encoding='utf8').write(s)

# ---------- Gradle (desugaring for notifications) ----------
for name in ['build.gradle.kts', 'build.gradle']:
    p = 'android/app/' + name
    if not os.path.exists(p):
        continue
    kts = name.endswith('.kts')
    g = open(p, encoding='utf8').read()
    flag = 'isCoreLibraryDesugaringEnabled = true' if kts else 'coreLibraryDesugaringEnabled true'
    dep = ('coreLibraryDesugaring("com.android.tools:desugar_jdk_libs:2.0.4")' if kts
           else "coreLibraryDesugaring 'com.android.tools:desugar_jdk_libs:2.0.4'")
    g = re.sub(r'compileOptions\s*\{', lambda m: 'compileOptions {\n        ' + flag, g, count=1)
    rel = '\n            isMinifyEnabled = false\n            isShrinkResources = false' if kts else '\n            minifyEnabled false\n            shrinkResources false'
    g = re.sub(r'(buildTypes\s*\{\s*(?:getByName\("release"\)|release)\s*\{)', lambda m: m.group(1) + rel, g, count=1)
    if os.environ.get('KS_B64'):
        open('android/app/nurnama.jks', 'wb').write(base64.b64decode(os.environ['KS_B64']))
        if kts:
            sc = ('signingConfigs {\n        create("release") {\n            storeFile = file("nurnama.jks")\n'
                  '            storePassword = System.getenv("KS_PASS")\n            keyAlias = System.getenv("KS_ALIAS")\n'
                  '            keyPassword = System.getenv("KS_PASS")\n        }\n    }\n')
            g = g.replace('signingConfigs.getByName("debug")', 'signingConfigs.getByName("release")')
        else:
            sc = ("signingConfigs {\n        release {\n            storeFile file('nurnama.jks')\n"
                  "            storePassword System.getenv('KS_PASS')\n            keyAlias System.getenv('KS_ALIAS')\n"
                  "            keyPassword System.getenv('KS_PASS')\n        }\n    }\n")
            g = g.replace('signingConfigs.debug', 'signingConfigs.release')
        g = re.sub(r'android\s*\{', lambda m: m.group(0) + '\n    ' + sc, g, count=1)
    if re.search(r'^dependencies\s*\{', g, re.M):
        g = re.sub(r'^(dependencies\s*\{)', lambda m: m.group(1) + '\n    ' + dep, g, count=1, flags=re.M)
    else:
        g += '\ndependencies {\n    ' + dep + '\n}\n'
    open(p, 'w', encoding='utf8').write(g)
    break

# ---------- Azan sound (optional) ----------
for f in ['azan.mp3', 'audio/azan.mp3']:
    if os.path.exists(f):
        os.makedirs('android/app/src/main/res/raw', exist_ok=True)
        shutil.copy(f, 'android/app/src/main/res/raw/azan.mp3')
        break
print('setup done')
