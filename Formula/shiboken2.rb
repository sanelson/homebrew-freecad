class Shiboken2 < Formula
  include Language::Python::Virtualenv

  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.12.0-src/pyside-setup-everywhere-src-5.12.0.tar.xz"
  sha256 "890149628a6c722343d6498a9f7e1906ce3c10edcaef0cc53cd682c1798bef51"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.12"

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "python@2"
  depends_on "qt"

  # Install numpy as a resource stanza so we can restrict it to python@2 (i.e. avoid numpy formula dependency in python 3)
  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2d/80/1809de155bad674b494248bcfca0e49eb4c5d8bee58f26fe7a0dd45029e2/numpy-1.15.4.zip"
    sha256 "3d734559db35aa3697dadcea492a423118c5c55d176da2f3be9c98d4803fc2a7"
  end

  def install
    qt = Formula["qt"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    venv = virtualenv_create(libexec)
    venv.pip_install resource("numpy")

    # Building the tests, is effectively a test of Shiboken
    mkdir "macbuild" do
      version = Language::Python.major_minor_version "python2"
      args = std_cmake_args
      args << "-DBUILD_TESTS=ON"
      args << "-DUSE_PYTHON_VERSION=#{version}"
      args << "-DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake/"
      args << "-DOSX_USE_LIBCPP=ON"
      args << "../sources/shiboken2"

      system "cmake", *args
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  test do
    system "#{bin}/shiboken2", "--version"
  end
end
