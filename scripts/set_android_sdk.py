from pathlib import Path
import re

kts = Path('android/app/build.gradle.kts')
groovy = Path('android/app/build.gradle')
if kts.exists():
    p = kts
    s = p.read_text(encoding='utf-8')
    s = re.sub(r'compileSdk\s*=\s*flutter\.compileSdkVersion', 'compileSdk = 36', s)
    s = re.sub(r'targetSdk\s*=\s*flutter\.targetSdkVersion', 'targetSdk = 36', s)
elif groovy.exists():
    p = groovy
    s = p.read_text(encoding='utf-8')
    s = re.sub(r'compileSdkVersion\s+flutter\.compileSdkVersion', 'compileSdkVersion 36', s)
    s = re.sub(r'targetSdkVersion\s+flutter\.targetSdkVersion', 'targetSdkVersion 36', s)
else:
    raise SystemExit('Android app Gradle file not found')
p.write_text(s, encoding='utf-8')
print('Android compileSdk/targetSdk set to 36')
