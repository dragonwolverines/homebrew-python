require 'formula'

class Scipy < Formula
  homepage 'http://www.scipy.org'
  url 'http://downloads.sourceforge.net/project/scipy/scipy/0.12.0/scipy-0.12.0.tar.gz'
  sha1 '1ba2e2fc49ba321f62d6f78a5351336ed2509af3'
  head 'https://github.com/scipy/scipy.git'
  # devel do
  #   url 'not yet but will be for 0.13'
  #   sha1 'todo'
  # end

  depends_on :python => :recommended
  depends_on :python3 => :optional
  depends_on 'numpy'
  depends_on 'swig' => :build
  depends_on :fortran

  option 'with-openblas', "Use openBLAS (slower for LAPACK functions) instead of Apple's Accelerate Framework"
  depends_on 'homebrew/science/openblas' => :optional

  def install
    if build.with? 'openblas'
      # For maintainers:
      # Check which BLAS/LAPACK numpy actually uses via:
      # xcrun otool -L /usr/local/Cellar/scipy/<version>/lib/python2.7/site-packages/scipy/linalg/_flinalg.so
      # or the other .so files.
      openblas_dir = Formula.factory('openblas').opt_prefix
      # Setting ATLAS to None is important to prevent numpy from always
      # linking against Accelerate.framework.
      ENV['ATLAS'] = "None"
      ENV['BLAS'] = ENV['LAPACK'] = "#{openblas_dir}/lib/libopenblas.dylib"
    end

    python do
      # gfortran is gnu95
      system python, "setup.py", "build", "--fcompiler=gnu95", "install", "--prefix=#{prefix}"
    end
  end

  test do
    python do
      system "python", "-c", "import scipy; scipy.test()"
    end
  end

  def caveats
    python.standard_caveats if python
  end
end
