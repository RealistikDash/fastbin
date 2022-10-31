from setuptools import setup
from setuptools import Extension
from Cython.Build import cythonize as cythonise

setup(
    ext_modules=cythonise(Extension(
        "fastbin.writer", ["fastbin/writer.pyx"]
    ))
)
