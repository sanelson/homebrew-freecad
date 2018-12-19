class Shiboken2 < Formula
  desc "GeneratorRunner plugin that outputs C++ code for CPython extensions"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.12.0-src/pyside-setup-everywhere-src-5.12.0.tar.xz"
  sha256 "890149628a6c722343d6498a9f7e1906ce3c10edcaef0cc53cd682c1798bef51"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.12"

  depends_on "cmake" => :build
  depends_on "llvm"
  depends_on "numpy"
  depends_on "qt"

  option "without-python", "Build without python 2 support"
  depends_on "python@2" => :recommended
  depends_on "python" => :optional

  def install
    qt = Formula["qt"]

    ENV["LLVM_INSTALL_DIR"] = Formula["llvm"].opt_prefix

    Language::Python.each_python(build) do |_python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args

        # Building the tests, is effectively a test of Shiboken
        args << "-DBUILD_TESTS=ON"
        args << "-DUSE_PYTHON_VERSION=#{version}"
        args << "-DCMAKE_PREFIX_PATH=#{qt.prefix}/lib/cmake/"
        args << "../sources/shiboken2"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
    end
  end

  test do
    system "#{bin}/shiboken2", "--version"
  end
end
