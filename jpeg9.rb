class Jpeg9 < Formula
  desc "JPEG image manipulation library"
  homepage "http://www.ijg.org"
  url "http://www.ijg.org/files/jpegsrc.v9b.tar.gz"
  version "9.1"
  sha256 "240fd398da741669bf3c90366f58452ea59041cacc741a489b99f2f6a0bad052"

  bottle do
    cellar :any
    sha256 "b9125a19cf663a93035bb506c518076515397d6a7ba9b748283bdc9cf141d371" => :el_capitan
    sha256 "3aebd7cf46e589ffe9510d770e1c76fb67e2faa1866b00f221aacb0d15e7f5b8" => :yosemite
    sha256 "da27dd200099902e1077cb9997f72882226be2681744dfe3cdfc098e196a1e84" => :mavericks
  end

  keg_only "Conflicts with jpeg in main repository."

  option :universal

  def install
    ENV.universal_binary if build.universal?

    # Builds static and shared libraries.
    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make", "install"
  end

  test do
    system "#{bin}/djpeg", test_fixtures("test.jpg")
  end
end
