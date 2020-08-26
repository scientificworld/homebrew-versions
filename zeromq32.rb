class Zeromq32 < Formula
  desc "High-performance, asynchronous messaging library"
  homepage "http://www.zeromq.org/"
  url "http://download.zeromq.org/zeromq-3.2.5.tar.gz"
  sha256 "09653e56a466683edb2f87ee025c4de55b8740df69481b9d7da98748f0c92124"

  bottle do
    cellar :any
    sha256 "616493db0ef76c1f55d93fa7cc3b253fe6237d06ea57cfd9d25e28c1c4823ee7" => :yosemite
    sha256 "fdaf595b9d71b5e0ff1485b938fa8ed6cd1766f8944b1d2afa790dfaae5853b1" => :mavericks
    sha256 "28d6eab45c2a388ae1a25703889b4e0477f3c1d8e9fb9fc868b9884f9f735d49" => :mountain_lion
  end

  option :universal
  option "with-pgm", "Build with PGM extension"

  depends_on "pkg-config" => :build
  depends_on "libpgm" if build.with? "pgm"

  def install
    ENV.universal_binary if build.universal?

    args = ["--disable-dependency-tracking", "--prefix=#{prefix}"]
    if build.with? "pgm"
      # Use HB libpgm-5.2 because their internal 5.1 is b0rked.
      ENV["OpenPGM_CFLAGS"] = `pkg-config --cflags openpgm-5.2`.chomp
      ENV["OpenPGM_LIBS"] = `pkg-config --libs openpgm-5.2`.chomp
      args << "--with-system-pgm"
    end

    system "./configure", *args
    system "make"
    system "make", "install"
  end

  def caveats; <<-EOS.undent
    To install the zmq gem on 10.6 with the system Ruby on a 64-bit machine,
    you may need to do:

        ARCHFLAGS="-arch x86_64" gem install zmq -- --with-zmq-dir=#{opt_prefix}
    EOS
  end

  test do
    (testpath/"test.c").write <<-EOS.undent
      #include <zmq.h>
      #include <assert.h>

      int main (void)
      {
          void *context = zmq_ctx_new ();
          void *responder = zmq_socket (context, ZMQ_REP);
          int rc = zmq_bind (responder, "tcp://*:5555");
          assert (rc == 0);

          return 0;
      }
    EOS
    system ENV.cc, "-I#{include}", "-L#{lib}", "-lzmq",
           testpath/"test.c", "-o", "test"
    system "./test"
  end
end
