Torch-MLIR with LLVM 21.1.8 on Fedora 41+ and MacOS Sequoia.
============================================================

This is my fork / port of Torch-MLIR built with LLVM 21.1.8 and PyTorch 2.7.1
on Fedora 41 and 43 and MacOS Sequoia.

Why am I doing this: I'm writing a Compiler for PyTorch, and I want to use
Torch-MLIR and ONNX-MLIR. The problem is that each and every one of these
projects uses their own version / commit of LLVM, neither of which is a
canonical numbered release. A bit of insanity ensues. :-)

I'm trying to mitigate this insanity for my own sake. Order shall be restored. :-P

I had to make some changes / additions to LLVM 21.1.8. You can get my version
of LLVM 21.1.8 from here - just search for it in my repos list. It has build
scripts too.

The build scripts are in the `build-scripts` toplevel directory.

The cumulative patch for Torch-MLIR is in the `patches` toplevel directory.

How to build:

1. Clone this repo.
2. Create a build directory parallel to the `torch-mlir` directory named `build-torch-mlir`.
3. Create an install directory parallel to the `torch-mlir` directory named `install-torch-mlir`.
4. Copy the build scripts - either for Linux or MacOS - to the `build-torch-mlir` directory.
5. Run `./run-cmake-configure-${linux|macos}.sh` script from the build directory.
6. When it's finished, run the `build-torch-mlir-${linux|macos}.sh` script to build.
7. When that one is finished, run the `install-torch-mlir-${linux|macos}.sh script. This script will install what's needed into the `install-torch-mlir` directory.
8. I added the RPM spec file for Torch-MLIR on Linux in the `build-scripts` directory.

That's it. :-)

