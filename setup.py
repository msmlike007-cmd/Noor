import os, re, math, shutil
from PIL import Image, ImageDraw

# ---------- Logo (matches the in-app logo) ----------
def bez(a, b, c, n=40):
    out = []
    for i in range(n + 1):
        t = i / n
        out.append(((1-t)**2*a[0] + 2*(1-t)*t*b[0] + t*t*c[0],
                    (1-t)**2*a[1] + 2*(1-t)*t*b[1] + t*t*c[1]))
    return out

def star(cx, cy, ro, ri):
    pts = []
    for i in range(10):
        r = ro if i % 2 == 0 else ri
        a = -math.pi/2 + i*math.pi/5
        pts.append((cx + r*math.cos(a), cy + r*math.sin(a)))
    return pts

def art(size, k, bg):
    S = size * 2
    img = Image.new('RGBA', (S, S), (11, 61, 46, 255) if bg else (0, 0, 0, 0))
    P = lambda x, y: ((0.5 + (x-0.5)*k)*S, (0.5 + (y-0.5)*k)*S)
    gold = (212, 175, 55, 255)
    m = Image.new('L', (S, S), 0)
    md = ImageDraw.Draw(m)
    def circ(cx, cy, r, fill):
        x, y = P(cx, cy); rr = r*k*S
        md.ellipse([x-rr, y-rr, x+rr, y+rr], fill=fill)
    circ(.5, .36, .22, 255)
    circ(.57, .32, .19, 0)
    img.paste(Image.new('RGBA', (S, S), gold), (0, 0), m)
    d = ImageDraw.Draw(img)
    dome = bez(P(.30, .80), P(.30, .62), P(.5, .60)) + bez(P(.5, .60), P(.70, .62), P(.70, .80))
    d.polygon(dome, fill=gold)
    d.rectangle([P(.28, .80), P(.72, .84)], fill=gold)
    d.polygon([P(*p) for p in star(.60, .30, .05, .02)], fill=gold)
    return img.resize((size, size), Image.LANCZOS)

os.makedirs('assets', exist_ok=True)
art(1024, 1.0, True).save('assets/icon.png')
art(1024, 0.62, False).save('assets/icon_fg.png')

# ---------- Manifest ----------
mf = 'android/app/src/main/AndroidManifest.xml'
s = open(mf, encoding='utf8').read()
perms = ''.join('<uses-permission android:name="android.permission.%s"/>\n' % p for p in [
    'ACCESS_FINE_LOCATION', 'ACCESS_COARSE_LOCATION', 'POST_NOTIFICATIONS', 'SCHEDULE_EXACT_ALARM',
    'USE_EXACT_ALARM', 'RECEIVE_BOOT_COMPLETED', 'VIBRATE', 'WAKE_LOCK', 'INTERNET', 'ACCESS_NETWORK_STATE'])
s = re.sub(r'(<manifest[^>]*>)', lambda m: m.group(1) + '\n' + perms, s, count=1)
recv = '''
<receiver android:exported="false" android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver"/>
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
