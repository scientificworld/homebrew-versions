class GstPluginsBad010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gst-plugins-bad/gst-plugins-bad-0.10.23.tar.bz2"
  sha256 "0eae7d1a1357ae8377fded6a1b42e663887beabe0e6cc336e2ef9ada42e11491"
  revision 1

  bottle do
    sha256 "413d08dd42855899df225b20b391a9e7ab37da5f9d46cfbcdaeb8ad906cddb01" => :yosemite
    sha256 "24429ab0e2e44c457a914131c91fcdd5367794366593c6ed192ba1de22f5ae8b" => :mavericks
    sha256 "7265d55c630ed8de96a59257d47640cbd664ec31bfbb5f1f90413291c716b1a8" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base010"
  depends_on "openssl"

  # These optional dependencies are based on the intersection of
  # gst-plugins-bad-0.10.21/REQUIREMENTS and Homebrew formulae
  depends_on "dirac" => :optional
  depends_on "libdvdread" => :optional
  depends_on "libmms" => :optional

  # These are not mentioned in REQUIREMENTS, but configure look for them
  depends_on "libexif" => :optional
  depends_on "faac" => :optional
  depends_on "faad2" => :optional
  depends_on "libsndfile" => :optional
  depends_on "schroedinger" => :optional
  depends_on "rtmpdump" => :optional

  def install
    ENV.append "CFLAGS", "-no-cpp-precomp -funroll-loops -fstrict-aliasing"
    system "./configure", "--prefix=#{prefix}",
                          "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-sdl"
    system "make"
    system "make", "install"
  end
end
