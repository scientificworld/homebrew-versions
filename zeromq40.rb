class Zeromq40 < Formula
  desc "High-performance, asynchronous messaging library"
  homepage "http://www.zeromq.org/"
  url "https://github.com/zeromq/zeromq4-x/releases/download/v4.0.8/zeromq-4.0.8.tar.gz"
  sha256 "56b652e622ee30456d3c2ce86d8b6a979a00bfe4ea3828d483a5e90864dac1dc"

  bottle do
    cellar :any
    sha256 "2bfd5e276813f742b84f02fd87b9235ba9845fd1c84f57a282fabc5b0ca37d0a" => :el_capitan
    sha256 "fe34e4169e00c7ecb92820080d0d0c4271de50f323b58f10280933c46c55c05c" => :yosemite
    sha256 "b492c298f61faa6eda6345807b2357f4761c533d21bd4197d4d7aa5f3e2a0acc" => :mavericks
  end

  option :universal
  option "with-libpgm", "Build with PGM extension"

  depends_on "pkg-config" => :build
  depends_on "libpgm" => :optional
  depends_on "libsodium" => :optional

  conflicts_with "zeromq", :because => "Differing version of the same formula"

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    if build.with? "libpgm"
      # Use HB libpgm-5.2 because their internal 5.1 is b0rked.
      ENV["OpenPGM_CFLAGS"] = `pkg-config --cflags openpgm-5.2`.chomp
      ENV["OpenPGM_LIBS"] = `pkg-config --libs openpgm-5.2`.chomp
      args << "--with-system-pgm"
    end

    if build.with? "libsodium"
      args << "--with-libsodium"
    else
      args << "--without-libsodium"
    end

    system "./autogen.sh" if build.head?
    system "./configure", *args
    system "make"
    system "make", "install"
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <assert.h>
      #include <zmq.h>

      int main()
      {
        zmq_msg_t query;
        assert(0 == zmq_msg_init_size(&query, 1));
        return 0;
      }
    EOS
    system ENV.cc, "test.c", "-L#{lib}", "-lzmq", "-o", "test"
    system "./test"
  end
end
