class GstPluginsGood010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gst-plugins-good/gst-plugins-good-0.10.31.tar.bz2"
  sha256 "7e27840e40a7932ef2dc032d7201f9f41afcaf0b437daf5d1d44dc96d9e35ac6"

  bottle do
    sha256 "9e5accf0d6347e55564baf11360870dd8ea0340323c19325fe4a728d153a8c8d" => :yosemite
    sha256 "a3deea24416800ea6bf996f9ab63233e5aeb23848d8733d77d9f1ec3a7d7a8cc" => :mavericks
    sha256 "e84402c150693fa0719230a9947449fabd3d637c8400f3ace4e0302847935304" => :mountain_lion
  end

  depends_on :x11
  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base010"
  depends_on "cairo"

  # The set of optional dependencies is based on the intersection of
  # gst-plugins-good-0.10.30/REQUIREMENTS and Homebrew formulae
  depends_on "orc" => :optional
  depends_on "gtk+" => :optional
  depends_on "check" => :optional
  depends_on "aalib" => :optional
  depends_on "libcdio" => :optional
  depends_on "esound" => :optional
  depends_on "flac" => :optional
  depends_on "jpeg" => :optional
  depends_on "libcaca" => :optional
  depends_on "libdv" => :optional
  depends_on "libshout" => :optional
  depends_on "speex" => :optional
  depends_on "taglib" => :optional
  depends_on "libsoup" => :optional

  def install
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--disable-schemas-install",
                          "--disable-gtk-doc",
                          "--disable-goom",
                          "--with-default-videosink=ximagesink"
    system "make"
    system "make", "install"
  end
end
