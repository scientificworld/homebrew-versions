class GstFfmpeg010 < Formula
  homepage "http://gstreamer.freedesktop.org/"
  url "https://gstreamer.freedesktop.org/src/gst-ffmpeg/gst-ffmpeg-0.10.13.tar.bz2"
  sha256 "76fca05b08e00134e3cb92fa347507f42cbd48ddb08ed3343a912def187fbb62"

  bottle do
    sha256 "e2b235b7fad36a8dbac8bcb4f67be0029bb875750c5dce53c288bb66a42018d5" => :yosemite
    sha256 "7dbd43f72c6053da45118caa49a27e766dd0e8107c80d6a8cd6a2c8e60de7199" => :mavericks
    sha256 "8ab9cab615859d33de819a0a314de82f8d2b70bdffea9489f7d82f57614b2ca9" => :mountain_lion
  end

  depends_on "pkg-config" => :build
  depends_on "gettext"
  depends_on "gst-plugins-base010"

  def install
    args = %W[
      --disable-dependency-tracking
      --disable-silent-rules
      --prefix=#{prefix}
      --with-ffmpeg-extra-configure=--cc=#{ENV.cc}
    ]

    system "./configure", *args
    system "make", "install"
  end
end
