class Freecad < Formula
  desc "Parametric 3D modeler"
  homepage "https://www.freecadweb.org"
  url "https://github.com/FreeCAD/FreeCAD/archive/0.17.tar.gz"
  sha256 "ae017393476b6dc7f1192bcaf91ceedc2f9b791f2495307ce7c45efadb5266fb"
  head "https://github.com/FreeCAD/FreeCAD.git", :branch => "master"

  # Debugging Support
  option "with-debug", "Enable debug build"

  # Option to build with legacy qt4
  option "with-qt4"

  # Optionally install packaging dependencies
  option "with-packaging-utils"

  # Build dependencies
  depends_on "ccache"  => :build
  depends_on "cmake"   => :build

  # Required dependencies
  depends_on "swig" => :build
  depends_on "boost-python@1.59" # depends on python@2
  depends_on "FreeCAD/freecad/coin"
  depends_on "freecad/freecad/matplotlib"
  depends_on "freecad/freecad/med-file"
  depends_on "FreeCAD/freecad/nglib"
  depends_on "FreeCAD/freecad/pivy"
  depends_on "freetype"
  depends_on :macos => :sierra
  depends_on "opencascade"
  depends_on "orocos-kdl"
  depends_on "python@2"
  depends_on "vtk"
  depends_on "xerces-c"
  if build.with?("qt4")
    depends_on "cartr/qt4/qt@4"
    depends_on "cartr/qt4/pyside-tools@1.2"
  else
    depends_on "qt"
    depends_on "qtwebkit"
    depends_on "FreeCAD/freecad/pyside2-tools"
    depends_on "webp"
  end

  if build.with?("packaging-utils")
    depends_on "node"
    depends_on "jq"
  end

  def install
    if build.with?("packaging-utils")
      system "node", "install", "-g", "app_dmg"
    end

    # Set up needed cmake args
    args = std_cmake_args
    if build.without?("qt4")
      args << "-DBUILD_QT5=ON"
      args << '-DCMAKE_PREFIX_PATH="' + Formula["qt"].opt_prefix + "/lib/cmake;" + Formula["qtwebkit"].opt_prefix + '/lib/cmake"'
    end
    args << %W[
      -DBUILD_FEM_NETGEN:BOOL=ON
      -DFREECAD_USE_EXTERNAL_KDL=ON
      -DCMAKE_BUILD_TYPE=#{build.with?("debug") ? "Debug" : "Release"}
    ]

    mkdir "Build" do
      system "cmake", *args, ".."
      system "make", "-j#{ENV.make_jobs}", "install"
    end
  end

  def caveats; <<-EOS.undent
    After installing FreeCAD you may want to do the following:

    1. Amend your PYTHONPATH environmental variable to point to
       the FreeCAD directory
         export PYTHONPATH=#{bin}:$PYTHONPATH
  EOS
  end
end
