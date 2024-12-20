import sys
import shutil
import subprocess
from os.path import join, exists, basename, dirname


def run_spw(*args: str):
    base_dir = dirname(__file__)
    spwriter = join(base_dir, "SwiftPackageWriter")
    subprocess.run([
        spwriter,
        *args
    ])

def main():
    args = sys.argv[1:]
    run_spw(*args)

if __name__ == "__main__":
    main()