class Coin < Formula
  desc "Retained-mode toolkit for 3D graphics development"
  homepage 'https://bitbucket.org/Coin3D/coin/wiki/Home'
  url 'https://bitbucket.org/Coin3D/coin/downloads/Coin-3.1.3.tar.gz'
  sha256 '583478c581317862aa03a19f14c527c3888478a06284b9a46a0155fa5886d417'

  bottle do
    root_url "https://github.com/freecad/homebrew-freecad/releases/download/0.17"
    sha256 "d434e5e7dcf9536a961f3025c3ae135cc4f3233f25587a27f81bc02ff9f3abca" => :el_capitan
    sha256 "035234f145a77884883198dda0911a2539f48eebd4523956ff7cc4dc1ab4ae9d" => :yosemite
  end

  option "without-soqt", "Build without SoQt"
  option "without-framework", "Install as a library; do not package as a Framework"

  if build.with? "soqt"
    depends_on "pkg-config" => :build
    depends_on "qt"
  end

  resource "soqt" do
    url "https://bitbucket.org/Coin3D/coin/downloads/SoQt-1.5.0.tar.gz"
    sha256 'f6a34b4c19e536c00f21aead298cdd274a7a0b03a31826fbe38fc96f3d82ab91'
  end

  # https://bitbucket.org/Coin3D/coin/pull-request/3/missing-include/diff
  patch do
    url "https://bitbucket.org/cbuehler/coin/commits/e146a6a93a6b807c28c3d73b3baba80fa41bc5f6/raw"
    sha256 '6ecbd868ed574339b7fec3882e5fdccd40a60094800f9b5c081899091fdc3ab5'
  end
 
  # https://bitbucket.org/Coin3D/coin/issue/23/xcode-clang-error-compiling-freetypecpp
  # Fixes freetype.cpp build issue
  patch :p0 do
    url "https://bitbucket.org/Coin3D/coin/issue-attachment/23/Coin3D/coin/1351441783.52/23/fix-weird-error.diff"
    sha256 'ab0c44f55c2e102ea641140652c1a02266b63b075266dd1e8b5e08599fc086e9'
  end

  # Patch Info.plist xml to be well-formed
  patch :DATA

  def install
    # https://bitbucket.org/Coin3D/coin/issue/47 (fix misspelled test flag)
    inreplace "configure", '-fno-for-scoping', '-fno-for-scope'

    # https://bitbucket.org/Coin3D/coin/issue/45 (suppress math-undefs)
    # http://ftp.netbsd.org/pub/pkgsrc/current/pkgsrc/graphics/Coin/patches/patch-include_Inventor_C_base_math-undefs.h
    inreplace "include/Inventor/C/base/math-undefs.h", "#ifndef COIN_MATH_UNDEFS_H", "#if false"

    system "./configure", "--disable-debug", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          build.with?("framework") ? "--with-framework-prefix=#{frameworks}" : "--without-framework"

    system "make install"

    if build.with? "soqt"
      resource("soqt").stage do
        ENV.deparallelize

        # https://bitbucket.org/Coin3D/coin/issue/40#comment-7888751
        inreplace "configure", /^(LIBS=\$sim_ac_uniqued_list)$/, "# \\1"

        system "./configure", "--disable-debug",
                              "--disable-dependency-tracking",
                              build.with?("framework") ? "--with-framework-prefix=#{frameworks}" : "--without-framework",
                              "--prefix=#{prefix}"

        system "make", "install"
      end
    end
  end
end

__END__
diff --git a/Info.plist.in b/Info.plist.in
index 0116d77..97d5831 100644
--- a/Info.plist.in
+++ b/Info.plist.in
@@ -7,7 +7,7 @@
 	<key>CFBundleExecutable</key>
 	<string>Inventor</string>
 	<key>CFBundleGetInfoString</key>
-	<string>Coin framework, copyright Kongsberg Oil & Gas Technologies 1998-2010</string>
+	<string>Coin framework, copyright Kongsberg Oil &amp; Gas Technologies 1998-2010</string>
 	<key>CFBundleIdentifier</key>
 	<string>org.coin3d.Coin.framework</string>
 	<key>CFBundleInfoDictionaryVersion</key>
@@ -23,6 +23,6 @@
 	<key>CFBundleVersion</key>
 	<string>@COIN_VERSION@</string>
 	<key>NSHumanReadableCopyright</key>
-	<string>Copyright Kongsberg Oil & Gas Technologies 1998-2010</string>
+	<string>Copyright Kongsberg Oil &amp; Gas Technologies 1998-2010</string>
 </dict>
 </plist>

