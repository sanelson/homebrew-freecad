class CoinAT400 < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage "https://coin3d.github.io"
  url "https://github.com/coin3d/coin", using: :git, tag: "Coin-4.0.0"
  version "4.0.0"
  head "https://github.com/coin3d/coin", using: :git

  bottle do
    root_url "https://justyour.parts:8080/freecad"
    sha256 cellar: :any, big_sur:  "7ffc242e36407db7cd5195cd62e9b6998b6114e9a7fdf70adadecfef0507e316"
    sha256 cellar: :any, catalina: "841ef05f4072eedc91a16845e3a8ed2e4c941faef5b338b7fd424649806de983"
  end

  keg_only "provided by homebrew"

  option "with-docs",       "Install documentation"
  option "with-threadsafe", "Include Thread safe traverals (experimental)"

  depends_on "cmake"   => :build
  depends_on "doxygen" => :build if build.with? "docs"
  depends_on "#{@tap}/boost@1.75.0"

  def install
    cmake_args = std_cmake_args
    cmake_args << "-DCOIN_THREADSAFE:BOOL=OFF" if build.without? "threadsafe"
    cmake_args << "-DCOIN_BUILD_DOCUMENTATION:BOOL=OFF" if build.without? "docs"
    cmake_args << "-DCOIN_USE_CPACK:BOOL=OFF"

    mkdir "build-lib" do
      system "mkdir", "../cpack.d"
      system "touch", "../cpack.d/CMakeLists.txt"
      system "cmake", "..", *cmake_args
      system "make", "install"
    end
  end
end
