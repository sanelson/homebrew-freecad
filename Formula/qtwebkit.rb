class Qtwebkit < Formula
  desc "Qt Webkit"
  homepage "https://wiki.qt.io/Qt_WebKit"
  url "https://code.qt.io/qt/qtwebkit.git", :branch => "5.212", :revision => "72cfbd7664f21fcc0e62b869a6b01bf73eb5e7da"
  version "5.212-72cfbd"
  revision 3
  head "https://code.qt.io/qt/qtwebkit.git", :branch => "5.212"

  keg_only "qt itself is keg only which implies the same for qt modules"

  depends_on "cmake" => :build
  depends_on "ninja" => :build
  depends_on "jpeg"
  depends_on "libpng"
  depends_on "qt"

  def install
    system "./Tools/Scripts/build-webkit", "--qt", "--prefix=#{prefix}", "--install"
  end
end
