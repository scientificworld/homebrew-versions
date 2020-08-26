class Libpng12 < Formula
  desc "Library for manipulating PNG images"
  homepage "http://www.libpng.org/pub/png/libpng.html"
  url "ftp://ftp.simplesystems.org/pub/libpng/png/src/libpng12/libpng-1.2.54.tar.xz"
  mirror "https://dl.bintray.com/homebrew/mirror/libpng-1.2.54.tar.xz"
  sha256 "cf85516482780f2bc2c5b5073902f12b1519019d47bf473326c2018bdff1d272"

  bottle do
    cellar :any
    sha256 "2107dbd088fdca3d22309544ab274ace0b8faaf543c04eae04aa07fcc0d37ac9" => :el_capitan
    sha256 "4c63b890aaede4ff236c566f0849d0b555daaf62381107ea7bd04e8287cd91cb" => :yosemite
    sha256 "ca5fbfd49eec9613db17ad8d142011780500e419ac3ebd4c5c73753774ce842b" => :mavericks
  end

  keg_only :provided_by_osx

  option :universal

  def install
    ENV.universal_binary if build.universal?

    system "./configure", "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}"
    system "make"
    system "make", "test"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <png.h>

      int main()
      {
        png_structp png_ptr;
        png_ptr = png_create_write_struct(PNG_LIBPNG_VER_STRING, NULL, NULL, NULL);
        png_destroy_write_struct(&png_ptr, (png_infopp)NULL);
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-I#{include}", "-L#{lib}", "-lpng", "-o", "test"
    system "./test"
  end
end
