class ImagemagickRuby186 < Formula
  homepage "http://www.imagemagick.org"
  url "https://download.sourceforge.net/project/imagemagick/old-sources/6.x/6.5/ImageMagick-6.5.9-10.tar.gz"
  sha256 "2330183bdecfda05f0503dcbf9cc74bc313211717194a2dbe4e3074564e9c2df"

  bottle do
    sha256 "2dd389cdca475b1a4dbdc3e0169f87ba86b7ea6bf44c6bd2b80f551a82589d78" => :yosemite
    sha256 "f6005dc489e5c0589a6305105c62904168c1ac27b0b90e721b1d89a445f7ddcc" => :mavericks
    sha256 "897d2e94a983c980cb3deb620273bd0ca81a9c2fa1df07d6fc6b42014b4729db" => :mountain_lion
  end

  depends_on "jpeg"
  depends_on "libwmf" => :optional
  depends_on "libtiff" => :optional
  depends_on "little-cms" => :optional
  depends_on "jasper" => :optional
  depends_on "ghostscript" => :optional
  depends_on "libpng12" # needs this old libpng. Not tested with 1.3 but 1.4 fails.
  depends_on :x11 => :optional

  def install
    ENV.deparallelize

    # versioned stuff in main tree is pointless for us
    inreplace "configure", "${PACKAGE_NAME}-${PACKAGE_VERSION}", "${PACKAGE_NAME}"

    args = %W[
      --prefix=#{prefix}
      --disable-dependency-tracking
      --enable-shared
      --without-maximum-compile-warnings
      --disable-osx-universal-binary
      --disable-static
      --with-modules
      --without-perl
      --disable-openmp
      --without-magick-plus-plus
    ]

    args << "--without-x" if build.without? "x11"

    if build.with? "ghostscript"
      args << "--without-ghostscript"
      args << "--with-gs-font-dir=#{HOMEBREW_PREFIX}/share/ghostscript/fonts"
    end

    system "./configure", *args
    system "make", "install"

    # We already copy these into the keg root
    (share+"ImageMagick/NEWS.txt").unlink
    (share+"ImageMagick/LICENSE").unlink
    (share+"ImageMagick/ChangeLog").unlink
  end
end
