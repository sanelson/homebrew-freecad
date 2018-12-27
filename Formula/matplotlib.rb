class DvipngRequirement < Requirement
  fatal false
  cask "mactex"

  satisfy { which("dvipng") }

  def message
    s = <<-EOS
      `dvipng` not found. This is optional for Matplotlib.
    EOS
    s += super
    s
  end
end

class NoExternalPyCXXPackage < Requirement
  fatal false

  satisfy do
    !quiet_system "python", "-c", "import CXX"
  end

  def message; <<-EOS
    *** Warning, PyCXX detected! ***
    On your system, there is already a PyCXX version installed, that will
    probably make the build of Matplotlib fail. In python you can test if that
    package is available with `import CXX`. To get a hint where that package
    is installed, you can:
        python -c "import os; import CXX; print(os.path.dirname(CXX.__file__))"
    See also: https://github.com/Homebrew/homebrew-python/issues/56
  EOS
  end
end

class Matplotlib < Formula
  desc "Python 2D plotting library"
  homepage "https://matplotlib.org"
  url "https://files.pythonhosted.org/packages/eb/a0/31b6ba00bc4dcbc06f0b80d1ad6119a9cc3081ecb04a00117f6c1ca3a084/matplotlib-2.2.3.tar.gz"
  sha256 "7355bf757ecacd5f0ac9dd9523c8e1a1103faadf8d33c22664178e17533f8ce5"
  head "https://github.com/matplotlib/matplotlib.git"

  bottle do
    root_url "https://homebrew.bintray.com/bottles-freecad"
    cellar :any
    sha256 "e5db6d40ff72bf417d099c5c45d04cc23d0fa69b4f5030d08fa7e2d9d04c97dd" => :sierra
  end

  option "without-python", "Build without python 3 support"
  option "with-cairo", "Build with cairo backend support"
  option "with-pygtk", "Build with pygtk backend support (python2 only)"
  option "with-tex", "Build with tex support"

  deprecated_option "with-gtk3" => "with-gtk+3"

  requires_py2 = []
  requires_py2 << "with-python@2" if build.with? "python@2"
  requires_py3 = []
  requires_py3 << "with-python" if build.with? "python"

  depends_on NoExternalPyCXXPackage => :build
  depends_on "pkg-config" => :build

  depends_on DvipngRequirement if build.with? "tex"
  depends_on "freetype"
  depends_on "libpng"
  depends_on "python@2" => :recommended
  depends_on "ghostscript" => :optional
  depends_on "gtk+3" => :optional
  depends_on "pygobject3" => requires_py3 if build.with? "gtk+3"
  depends_on "pygtk" => :optional
  depends_on "pygobject" if build.with? "pygtk"
  depends_on "pyqt" => [:optional] + requires_py2

  depends_on "python" => :optional

  if build.with? "cairo"
    depends_on "py2cairo" if build.with? "python@2"
    depends_on "py3cairo" if build.with? "python"
  end

  depends_on "tcl-tk" => :optional

  cxxstdlib_check :skip

  resource "Cycler" do
    url "https://files.pythonhosted.org/packages/c2/4b/137dea450d6e1e3d474e1d873cd1d4f7d3beed7e0dc973b06e8e10d32488/cycler-0.10.0.tar.gz"
    sha256 "cd7b2d1018258d7247a71425e9f26463dfb444d411c39569972f4ce586b0c9d8"
  end

  resource "pyparsing" do
    url "https://files.pythonhosted.org/packages/d0/09/3e6a5eeb6e04467b737d55f8bba15247ac0876f98fae659e58cd744430c6/pyparsing-2.3.0.tar.gz"
    sha256 "f353aab21fd474459d97b709e527b5571314ee5f067441dc9f88e33eecd96592"
  end

  resource "python-dateutil" do
    url "https://files.pythonhosted.org/packages/0e/01/68747933e8d12263d41ce08119620d9a7e5eb72c876a3442257f74490da0/python-dateutil-2.7.5.tar.gz"
    sha256 "88f9287c0174266bb0d8cedd395cfba9c58e87e5ad86b2ce58859bc11be3cf02"
  end

  resource "pytz" do
    url "https://files.pythonhosted.org/packages/cd/71/ae99fc3df1b1c5267d37ef2c51b7d79c44ba8a5e37b48e3ca93b4d74d98b/pytz-2018.7.tar.gz"
    sha256 "31cb35c89bd7d333cd32c5f278fca91b523b0834369e757f4c5641ea252236ca"
  end

  resource "six" do
    url "https://files.pythonhosted.org/packages/dd/bf/4138e7bfb757de47d1f4b6994648ec67a51efe58fa907c1e11e350cddfca/six-1.12.0.tar.gz"
    sha256 "d16a0141ec1a18405cd4ce8b4613101da75da0e9a7aec5bdd4fa804d0e0eba73"
  end

  # Install numpy as a resource stanza so we can restrict it to python@2 (i.e. avoid numpy formula dependency in python 3)
  resource "numpy" do
    url "https://files.pythonhosted.org/packages/2d/80/1809de155bad674b494248bcfca0e49eb4c5d8bee58f26fe7a0dd45029e2/numpy-1.15.4.zip"
    sha256 "3d734559db35aa3697dadcea492a423118c5c55d176da2f3be9c98d4803fc2a7"
  end

  # python2 only
  resource "backports.functools_lru_cache" do
    url "https://files.pythonhosted.org/packages/57/d4/156eb5fbb08d2e85ab0a632e2bebdad355798dece07d4752f66a8d02d1ea/backports.functools_lru_cache-1.5.tar.gz"
    sha256 "9d98697f088eb1b0fa451391f91afb5e3ebde16bbdb272819fd091151fda4f1a"
  end

  # python2 only
  resource "subprocess32" do
    url "https://files.pythonhosted.org/packages/be/2b/beeba583e9877e64db10b52a96915afc0feabf7144dcbf2a0d0ea68bf73d/subprocess32-3.5.3.tar.gz"
    sha256 "6bc82992316eef3ccff319b5033809801c0c3372709c5f6985299c88ac7225c3"
  end

  def install
    inreplace "setupext.py",
              "'darwin': ['/usr/local/'",
              "'darwin': ['#{HOMEBREW_PREFIX}'"

    Language::Python.each_python(build) do |python, version|
      site_packages = libexec/"lib/python#{version}/site-packages"
      site_packages.mkpath
      ENV.prepend_path "PYTHONPATH", site_packages

      # Collect python 2 vs 3 resources (some python 2 specific)
      res = if version.to_s.start_with? "2"
        resources.map(&:name).to_set
      else
        resources.map(&:name).to_set - ["backports.functools_lru_cache", "subprocess32"]
      end
      res.each do |r|
        resource(r).stage do
          system python, *Language::Python.setup_install_args(libexec),
          "--install-lib", lib/"python#{version}/site-packages"
        end
      end
      # (lib/"python#{version}/site-packages/homebrew-matplotlib.pth").write "#{site_packages}\n"

      system python, *Language::Python.setup_install_args(prefix)
    end
  end

  def caveats
    s = <<-EOS
      If you want to use the `wxagg` backend, do `brew install wxpython`.
      This can be done even after the matplotlib install.
    EOS
    if build.with?("python") && !Formula["python"].installed?
      homebrew_site_packages = Language::Python.homebrew_site_packages
      user_site_packages = Language::Python.user_site_packages "python"
      s += <<-EOS
        If you use system python (that comes - depending on the OS X version -
        with older versions of numpy, scipy and matplotlib), you may need to
        ensure that the brewed packages come earlier in Python's sys.path with:
          mkdir -p #{user_site_packages}
          echo 'import sys; sys.path.insert(1, "#{homebrew_site_packages}")' >> #{user_site_packages}/homebrew.pth
      EOS
    end
    s
  end

  test do
    ENV["PYTHONDONTWRITEBYTECODE"] = "1"
    ["python", "python2"].each do |python|
      ENV.prepend_path "PATH", Formula[python].opt_libexec/"bin"
      system python, "-c", "import matplotlib"
    end
  end
end
