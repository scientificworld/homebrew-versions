class Srtp15 < Formula
  desc "Implementation of the Secure Real-time Transport Protocol (SRTP)"
  homepage "https://github.com/cisco/libsrtp"
  url "https://github.com/cisco/libsrtp/archive/v1.5.2.tar.gz"
  sha256 "86e1efe353397c0751f6bdd709794143bd1b76494412860f16ff2b6d9c304eda"

  bottle do
    cellar :any
    sha256 "0138197f62306eb4ab277f250355c5377f42447ad4355cc42e06b72fa7e5ff02" => :el_capitan
    sha256 "3e53f1b801ac37803cb277a9c48bd56c45066a0940000187f60b6c3966e0cae0" => :yosemite
    sha256 "4a7bff25018c02c889874b2d997fcf51db42be90aa22acdcda6d629de22daf50" => :mavericks
  end

  depends_on "pkg-config" => :build

  def install
    system "./configure", "--disable-debug",
                          "--prefix=#{prefix}"
    system "make", "shared_library"
    system "make", "install" # Can't go in parallel of building the dylib
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <srtp/srtp.h>
      #include <stdlib.h>

      int main() {
        err_status_t err;
        err = srtp_init();
        if (err != err_status_ok) {
          fputs("failed srtp_init", stderr);
          return 1;
        }
        err = srtp_shutdown();
        if (err != err_status_ok) {
          fputs("failed srtp_shutdown", stderr);
          return 1;
        }
        return 0;
      }
    EOS
    args = ["-L#{lib}"]
    args += %w[test.c -o test -lsrtp]
    system ENV.cc, *args
    system "./test"
  end
end
