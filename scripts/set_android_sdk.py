
from pathlib import Path
import subprocess
import re
import sys

MARKER = "// NOOR_NAMA_LINT_WORKAROUND"

def find_project_root():
    candidates = [
        Path.cwd(),
        Path(__file__).resolve().parent,
        Path(__file__).resolve().parent.parent,
    ]

    for candidate in candidates:
        for folder in [candidate, *candidate.parents]:
            if (folder / "pubspec.yaml").exists():
                return folder

    raise RuntimeError("Flutter project root (pubspec.yaml) not found.")


def run_command(command, cwd):
    print("Running:", " ".join(command))
    subprocess.run(command, cwd=cwd, check=True)


def create_android_if_missing(root):
    android_dir = root / "android"

    if android_dir.exists():
        print("Android folder already exists.")
        return

    print("Android folder not found. Creating Android platform...")

    run_command(
        ["flutter", "create", "--platforms=android", "."],
        root
    )

    if not android_dir.exists():
        raise RuntimeError("Android folder could not be created.")


def update_compile_sdk(root):
    candidates = [
        root / "android/app/build.gradle.kts",
        root / "android/app/build.gradle",
    ]

    for path in candidates:
        if not path.exists():
            continue

        content = path.read_text(encoding="utf-8")
        original = content

        if path.suffix == ".kts":
            content = re.sub(
                r"compileSdk\s*=\s*flutter\.compileSdkVersion",
                "compileSdk = 36",
                content
            )
        else:
            content = re.sub(
                r"compileSdkVersion\s+flutter\.compileSdkVersion",
                "compileSdkVersion 36",
                content
            )
            content = re.sub(
                r"compileSdk\s+flutter\.compileSdkVersion",
                "compileSdk 36",
                content
            )

        if content != original:
            path.write_text(content, encoding="utf-8")
            print("compileSdk updated:", path)
        else:
            print("compileSdk already configured or uses another format:", path)

        return

    raise RuntimeError("Android app Gradle file not found.")


def disable_crashing_release_lint(root):
    gradle_files = [
        root / "android/build.gradle",
        root / "android/build.gradle.kts",
    ]

    gradle_file = next(
        (path for path in gradle_files if path.exists()),
        None
    )

    if gradle_file is None:
        raise RuntimeError("Android root Gradle file not found.")

    content = gradle_file.read_text(encoding="utf-8")

    if MARKER in content:
        print("Lint workaround already added.")
        return

    workaround = f"""

{MARKER}
allprojects {{
    tasks.configureEach {{
        if (name == "lintVitalAnalyzeRelease") {{
            enabled = false
        }}
    }}
}}
"""

    gradle_file.write_text(
        content.rstrip() + "\n" + workaround,
        encoding="utf-8"
    )

    print("Release lint workaround added:", gradle_file)


def main():
    try:
        root = find_project_root()
        print("Project:", root)

        create_android_if_missing(root)
        update_compile_sdk(root)
        disable_crashing_release_lint(root)

        print("\\nNoor Nama Android configuration updated.")

    except Exception as error:
        print("\\nERROR:", error)
        sys.exit(1)


if __name__ == "__main__":
    main()
    
