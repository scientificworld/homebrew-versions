class GstPluginsUgly010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gst-plugins-ugly/gst-plugins-ugly-0.10.19.tar.bz2"
  sha256 "1ca90059275c0f5dca71d4d1601a8f429b7852baed0723e820703b977e2c8df0"

  bottle do
    sha256 "d31e63e1303fa3a8111cbff9ecbd72eb6cf9ac3607f81a9cd4e6b5f08600ac04" => :yosemite
    sha256 "d0d519f2b26419bdf5aa8d51dadde2d1f89856e5213aece5399128cb2c798f6b" => :mavericks
    sha256 "b3cd3c7daa0f5c6759b9cf67b89aa48ddf451c8084565c0d3bf922b9295f4620" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base010"

  # The set of optional dependencies is based on the intersection of
  # gst-plugins-ugly-0.10.17/REQUIREMENTS and Homebrew formulae
  depends_on "dirac" => :optional
  depends_on "mad" => :optional
  depends_on "jpeg" => :optional
  depends_on "libvorbis" => :optional
  depends_on "cdparanoia" => :optional
  depends_on "lame" => :optional
  depends_on "two-lame" => :optional
  depends_on "libshout" => :optional
  depends_on "aalib" => :optional
  depends_on "libcaca" => :optional
  depends_on "libdvdread" => :optional
  depends_on "sdl" => :optional
  depends_on "libmpeg2" => :optional
  depends_on "a52dec" => :optional
  depends_on "liboil" => :optional
  depends_on "flac" => :optional
  depends_on "gtk+" => :optional
  depends_on "pango" => :optional
  depends_on "theora" => :optional
  depends_on "libmms" => :optional
  depends_on "x264" => :optional
  depends_on "opencore-amr" => :optional
  # Does not work with libcdio 0.9

  def install
    ENV.append "CFLAGS", "-no-cpp-precomp -funroll-loops -fstrict-aliasing"

    args = %W[
      --disable-debug
      --disable-dependency-tracking
      --prefix=#{prefix}
      --mandir=#{man}
    ]

    if build.with? "opencore-amr"
      # Fixes build error, missing includes.
      # https://github.com/mxcl/homebrew/issues/14078
      nbcflags = `pkg-config --cflags opencore-amrnb`.chomp
      wbcflags = `pkg-config --cflags opencore-amrwb`.chomp
      ENV["AMRNB_CFLAGS"] = nbcflags + "-I#{HOMEBREW_PREFIX}/include/opencore-amrnb"
      ENV["AMRWB_CFLAGS"] = wbcflags + "-I#{HOMEBREW_PREFIX}/include/opencore-amrwb"
    else
      args << "--disable-amrnb" << "--disable-amrwb"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end
end
