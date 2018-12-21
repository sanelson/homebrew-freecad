class Pyside2Tools < Formula
  desc "PySide development tools (pyuic and pyrcc)"
  homepage "https://wiki.qt.io/PySide2"
  url "https://download.qt.io/official_releases/QtForPython/pyside2/PySide2-5.12.0-src/pyside-setup-everywhere-src-5.12.0.tar.xz"
  sha256 "890149628a6c722343d6498a9f7e1906ce3c10edcaef0cc53cd682c1798bef51"
  head "http://code.qt.io/pyside/pyside-setup.git", :branch => "5.12"

  depends_on "cmake" => :build
  depends_on "FreeCAD/freecad/pyside2"
  depends_on "python" => :recommended
  depends_on "python@2" => :recommended

  def install
    Language::Python.each_python(build) do |_python, version|
      mkdir "macbuild#{version}" do
        args = std_cmake_args
        args << "-DUSE_PYTHON_VERSION=#{version}"
        args << "-DOSX_USE_LIBCPP=ON"
        args << "../sources/pyside2-tools"

        system "cmake", *args
        system "make", "-j#{ENV.make_jobs}", "install"
      end
    end
  end
end
