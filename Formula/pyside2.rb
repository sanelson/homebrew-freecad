class Pyside2 < Formula
  desc "Python bindings for Qt5 and greater"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.12.0-src/pyside-setup-everywhere-src-5.12.0.tar.xz"
  sha256 "890149628a6c722343d6498a9f7e1906ce3c10edcaef0cc53cd682c1798bef51"
  head "http://code.qt.io/cgit/pyside/pyside-setup.git", :branch => "5.12"

  option "without-python", "Build without python 2 support"
  option "without-docs", "Skip building documentation"

  depends_on "cmake" => :build
  depends_on "sphinx-doc" => :build if build.with? "docs"
  depends_on "FreeCAD/freecad/shiboken2"
  depends_on "qt"
  depends_on "python@2" => :recommended
  depends_on "python" => :optional

  def install
    ENV.cxx11

    # This is a workaround for current problems with Shiboken2
    ENV["HOMEBREW_INCLUDE_PATHS"] = ENV["HOMEBREW_INCLUDE_PATHS"].sub(Formula["qt"].include, "")

    rm buildpath/"sources/pyside2/doc/CMakeLists.txt" if build.without? "docs"
    qt = Formula["qt"]

    # Add out of tree build because one of its deps, shiboken, itself needs an
    # out of tree build in shiboken.rb.
    Language::Python.each_python(build) do |_python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args + %W[
          -DUSE_PYTHON_VERSION=#{version}
          -DQT_SRC_DIR=#{qt.include}
          -DALTERNATIVE_QT_INCLUDE_DIR=#{qt.opt_prefix}/include
          -DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake
          -DOSX_USE_LIBCPP=ON
          -DBUILD_TESTS:BOOL=OFF
        ]
        args << "../sources/pyside2"
        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}"
        system "make", "install"
      end

      # Work-around to https://bugreports.qt.io/browse/PYSIDE-494
      # rm prefix/"lib/python2.7/site-packages/PySide2/QtTest.so"
    end

    # inreplace include/"PySide2/pyside2_global.h", qt.prefix, qt.opt_prefix
  end

  test do
    ["python", "python2"].each do |python|
      system python, "-c", "from PySide2 import QtCore"
    end
  end
end
