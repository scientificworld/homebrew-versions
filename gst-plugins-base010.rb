class GstPluginsBase010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gst-plugins-base/gst-plugins-base-0.10.36.tar.bz2"
  sha256 "2cd3b0fa8e9b595db8f514ef7c2bdbcd639a0d63d154c00f8c9b609321f49976"

  bottle do
    sha256 "a8b4f2d006de309842dba3547c64e0d8c815ab8d81786adae15e3f3c6325eab8" => :yosemite
    sha256 "5b5309d925799796c079c1c1ab21d087d055cd17a8d1b0d032781a2d121619e0" => :mavericks
    sha256 "b24984c21803c8aba964e8d79200d9125c47975a928be597e588436bd274d737" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gstreamer010"

  # The set of optional dependencies is based on the intersection of
  # gst-plugins-base-0.10.35/REQUIREMENTS and Homebrew formulae
  depends_on "orc" => :optional
  depends_on "gtk+" => :optional
  depends_on "libogg" => :optional
  depends_on "pango" => :optional
  depends_on "theora" => :optional
  depends_on "libvorbis" => :optional

  def install
    # gnome-vfs turned off due to lack of formula for it.
    args = %W[
      --prefix=#{prefix}
      --disable-debug
      --disable-dependency-tracking
      --enable-introspection=no
      --enable-experimental
      --disable-libvisual
      --disable-alsa
      --disable-cdparanoia
      --without-x
      --disable-x
      --disable-xvideo
      --disable-xshm
      --disable-gnome_vfs
    ]

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
