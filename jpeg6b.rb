class Jpeg6b < Formula
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v6b.tar.gz"
  sha256 "75c3ec241e9996504fe02a9ed4d12f16b74ade713972f3db9e65ce95cd27e35d"

  bottle do
    cellar :any
    sha256 "1c270f53c34c4183c52ad2101e7b47f5bddf6e5b431931bcc737dd76f1bd6270" => :yosemite
    sha256 "bf033c7f0bcdd1955574cf461a72633dfa9d2ce6415c6afabc00beddb287386f" => :mavericks
    sha256 "0dc3574f3c0133562c3806e93de1260d6dbcb67218e88b74d739f87f74df79a4" => :mountain_lion
  end

  depends_on "libtool" => :build

  def install
    bin.mkpath
    lib.mkpath
    include.mkpath
    man1.mkpath

    system "./configure", "--disable-dependency-tracking",
                          "--prefix=#{prefix}",
                          "--enable-shared"

    system "make", "install", "install-lib", "install-headers",
                   "mandir=#{man1}", "LIBTOOL=glibtool"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end
