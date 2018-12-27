class Pivy < Formula
  desc "Python bindings for Coin 3D"
  homepage "https://bitbucket.org/Coin3D/pivy/overview"
  url "https://bitbucket.org/Coin3D/pivy/get/d8c4fefe5a19954f23b6caff2931319976228b79.tar.gz"
  version "0.5.0-4b84e76"
  sha256 "43216e708ed51ded96f31116a22846aca53a16120cb7d7a9daf14296270dbb53"
  head "https://bitbucket.org/Coin3D/pivy", :using => :hg

  bottle do
    root_url "https://dl.bintray.com/freecad/bottles-freecad"
    cellar :any
    rebuild 3
    sha256 "01e80593ec91b255292d38557cf9b24b9a37ff7e70fa15b79a3e7b7f4d767788" => :high_sierra
    sha256 "6676b7ed0026ea0a5111e06632d54c69c85dd13be2792ec7d6f00b848b47658d" => :sierra
    sha256 "3bcf82cdcff322fae255fc4d55840aadc7a99540376f304371cb600103141305" => :el_capitan
  end

  depends_on "python@2" => :build
  depends_on "swig" => :build
  depends_on "FreeCAD/freecad/coin"

  def install
    system "python2", *Language::Python.setup_install_args(prefix)
  end
end
