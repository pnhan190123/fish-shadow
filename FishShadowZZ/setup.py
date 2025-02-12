from distutils.core import setup
from distutils.extension import Extension
from Cython.Distutils import build_ext
ext_modules = [
    Extension("function",  ["function.pyx"]),
    Extension("adb_tap",  ["adb_tap.pyx"]),
    Extension("image",  ["image.pyx"]),

]
setup(
    name = 'FishShadow 3',
    cmdclass = {'build_ext': build_ext},
    ext_modules = ext_modules
)

