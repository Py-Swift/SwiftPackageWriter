from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext
import subprocess
import os
from os.path import join, exists
import shutil
import sys
from pathlib import Path

class SPWExtension(Extension):
    def __init__(self, name: str):
        super().__init__(name, sources=[])
        self.sources = os.fspath(Path(name).resolve())

class BuildSwiftPackage(build_ext):
    
    def build_extension(self, ext: SPWExtension):
        print("Building SwiftPackageWriter:", ext.sources)
        cwd = ext.sources
        
        # build swift executable
        subprocess.run([
            "swift", "build",
            #"--package-path", cwd,
            "-c", "release"
            
        ])
        
        # copy to venv/bin
        bin = join(sys.prefix, "bin")
        print("destination bin:", bin)
        if exists(join(bin, "SwiftPackageWriter")):
            os.remove(join(bin, "SwiftPackageWriter"))
        shutil.copy(
            join(cwd, ".build", "release", "SwiftPackageWriter"),
            bin
        )
setup(
    name="SwiftPackageWriter",
    #scripts=["bin/SwiftPackageWriter",],
    # entry_points={
    #     "scripts": ["bin/SwiftPackageWriter"]
    # },
    ext_modules=[SPWExtension("")],
    cmdclass={"build_ext": BuildSwiftPackage}
)
