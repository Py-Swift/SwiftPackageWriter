from setuptools import setup, Extension
from setuptools.command.build_ext import build_ext

from setuptools.command.install import install

import subprocess
import os
from os.path import join, exists
import shutil
import sys
from pathlib import Path

class SPWExtension(Extension):
    def __init__(self):
        #super().__init__("", [os.fspath(Path("").resolve())])
        super().__init__("spw", ["./"])

class BuildSwiftPackage(build_ext):
    
    def build_extension(self, ext: SPWExtension):
        print("Building SwiftPackageWriter:", ext.sources)
        cwd = ext.sources[0]
        
        # build swift executable
        subprocess.run([
            "swift", "build",
            #"--package-path", cwd,
            "-c", "release"
            
        ])
        
        # copy to venv/bin
        
        
        
class InstallSwiftExecutable(install):
    
    def run(self):
        print("prefix", self.prefix)
        print("install_base", self.install_base)
        print("exec_prefix",self.exec_prefix)
        #raise NotImplementedError("prefix tested")
        bin = join(self.build_lib, "swiftpackagewriter")
        print("destination bin:", bin)
        
        
        if exists(join(bin, "SwiftPackageWriter")):
            os.remove(join(bin, "SwiftPackageWriter"))
        shutil.copy(
            join(os.getcwd(), ".build", "release", "SwiftPackageWriter"),
            bin
        )
        super().run()  

setup(
    #scripts=["bin/SwiftPackageWriter",],
    # entry_points={
    #     "scripts": ["bin/SwiftPackageWriter"]
    # },
    ext_modules=[SPWExtension()],
    cmdclass={
        "build_ext": BuildSwiftPackage,
        "install": InstallSwiftExecutable
    }
)
